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
  option :consul,
         description: 'consul server',
         long: '--consul SERVER',
         default: 'http://localhost:8500'

  option :service,
         description: 'a service managed by consul',
         short: '-s SERVICE',
         long: '--service SERVICE',
         default: 'consul'

  option :all,
         description: 'get all services in a non-passing status',
         short: '-a',
         long: '--all'

  option :fail_if_not_found,
         description: 'fail if no service is found',
         short: '-f',
         long: '--fail-if-not-found'

  # Get the check data for the service from consul
  #
  def acquire_service_data
    if config[:all]
      Diplomat::Health.state('any')
    else
      Diplomat::Health.checks(config[:service])
    end
  rescue Faraday::ConnectionFailed => e
    warning "Connection error occurred: #{e}"
  rescue StandardError => e
    unknown "Exception occurred when checking consul service: #{e}"
  end

  # Main function
  #
  def run
    Diplomat.configure do |dc|
      dc.url = config[:consul]
    end

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

    if failing.empty? && passing.empty?
      msg = "Could not find checks for any services"
      if config[:service]
        msg = "Could not find checks for service #{config[:service]}"
      end
      if config[:fail_if_not_found]
        critical msg
      else
        unknown msg
      end
    end
    critical failing unless failing.empty?
    ok passing unless passing.empty?
  end
end
