#! /usr/bin/env ruby
#
#   check-service-consul
#
# DESCRIPTION:
#   This plugin checks if consul says a service is 'passing' or
#   'critical'
#
# OUTPUT:
#   plain text
#
# PLATFORMS:
#   Linux
#
# DEPENDENCIES:
#   gem: sensu-plugin
#   gem: diplomat
#
# USAGE:
#   ./check-service-consul -s influxdb
#   ./check-service-consul -a
#
# NOTES:
#
# LICENSE:
#   Copyright 2015 Yieldbot, Inc. <Sensu-Plugins>
#   Released under the same terms as Sensu (the MIT license); see LICENSE
#   for details.
#

require 'sensu-plugin/check/cli'
require 'diplomat'

#
# Service Status
#
class ServiceStatus < Sensu::Plugin::Check::CLI
  option :service,
         description: 'a service managed by consul',
         short: '-s SERVICE',
         long: '--service SERVICE',
         default: 'consul'

  option :all,
         description: 'get all services in a non-passing status',
         short: '-a',
         long: '--all'

  # Get the check data for the service from consul
  #
  def acquire_service_data
    if config[:all]
      Diplomat::Health.checks
    else
      Diplomat::Health.checks(config[:service])
    end
  end

  # Main function
  #
  def run
    data = acquire_service_data
    passing = []
    failing = []
    data.each do |d|
      passing << {
        'node' => d['Node'],
        'service' => d['ServiceName'],
        'service_id' => d['ServiceID'],
        'notes' => d['Notes']
      } if d['Status'] == 'passing'
      failing << {
        'node' => d['Node'],
        'service' => d['ServiceName'],
        'service_id' => d['ServiceID'],
        'notes' => d['Notes']
      } if d['Status'] == 'failing'
    end
    unknown "Could not find service - are there checks defined?" if failing.empty? and passing.empty?
    critical failing unless failing.empty?
    ok passing unless passing.empty?
  end

end
