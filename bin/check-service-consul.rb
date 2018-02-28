#! /usr/bin/env ruby
# frozen_string_literal: true

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

  option :tags,
         description: 'filter services by a comma-separated list of tags (requires --service)',
         short: '-t TAGS',
         long: '--tags TAGS'

  option :all,
         description: 'get all services in a non-passing status (not compatible with --tags)',
         short: '-a',
         long: '--all'

  option :fail_if_not_found,
         description: 'fail if no service is found',
         short: '-f',
         long: '--fail-if-not-found'

  # Get the check data for the service from consul
  #
  def acquire_service_data
    if config[:tags] && config[:service]
      tags = config[:tags].split(',').to_set
      services = []
      Diplomat::Health.service(config[:service]).each do |s|
        if s['Service']['Tags'].to_set.superset? tags
          services.push(*s['Checks'])
        end
      end
      return services
    elsif config[:all]
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
    if config[:tags] && config[:all]
      critical 'Cannot specify --tags and --all simultaneously (Consul health/service/ versus health/state/).'
    end

    Diplomat.configure do |dc|
      dc.url = config[:consul]
    end

    data = acquire_service_data
    passing = []
    failing = []
    data.each do |d|
      if d['Status'] == 'passing'
        passing << {
          'node' => d['Node'],
          'service' => d['ServiceName'],
          'service_id' => d['ServiceID'],
          'notes' => d['Notes']
        }
      elsif d['Status'] == 'critical'
        failing << {
          'node' => d['Node'],
          'service' => d['ServiceName'],
          'service_id' => d['ServiceID'],
          'notes' => d['Notes']
        }
      end
    end

    if failing.empty? && passing.empty?
      msg = 'Could not find checks for any services'
      if config[:service]
        msg = "Could not find checks for service #{config[:service]}"
        if config[:tags]
          msg += " with tags #{config[:tags]}"
        end
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
