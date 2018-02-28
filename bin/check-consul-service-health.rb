#! /usr/bin/env ruby
# frozen_string_literal: true

#
#   check-consul-service-health
#
# DESCRIPTION:
#   This plugin assists in checking the check status of a Consul Service
#   In addition, it provides additional Yieldbot logic for Output containing
#   JSON.
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
#   ./check-consul-service-health -s influxdb
#   ./check-consul-service-health -a
#
# NOTES:
#
# LICENSE:
#   Copyright 2015 Yieldbot, Inc. <devops@yieldbot.com>
#   Released under the same terms as Sensu (the MIT license); see LICENSE
#   for details.
#

require 'sensu-plugin/check/cli'
require 'diplomat'
require 'json'

#
# Service Status
#
class CheckConsulServiceHealth < Sensu::Plugin::Check::CLI
  option :consul,
         description: 'consul server',
         long: '--consul SERVER',
         default: 'http://localhost:8500'

  option :nodename,
         description: 'check all consul services running on the specified node',
         short: '-n NODENAME',
         long: '--node NODENAME'

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
         description: 'get all services (not compatible with --tags)',
         short: '-a',
         long: '--all'

  option :fail_if_not_found,
         description: 'fail if no service is found',
         short: '-f',
         long: '--fail-if-not-found'

  # Get the service checks for the given service
  def acquire_service_data
    if config[:tags] && config[:service]
      tags = config[:tags].split(',').to_set
      services = []
      Diplomat::Health.service(config[:service]).each do |s|
        if s['Service']['Tags'].to_set.superset? tags
          services.push(*s['Checks'])
        end
      end
      services
    elsif config[:nodename]
      data = []
      begin
        services = Diplomat::Node.get(config[:nodename]).Services
      rescue StandardError
        services = {}
      end
      services.each_value do |service|
        Diplomat::Health.checks(service['Service']).each do |check|
          data.push(check) if check.Node == config[:nodename]
        end
      end
      data
    elsif config[:all]
      Diplomat::Health.state('any')
    else
      Diplomat::Health.checks(config[:service])
    end
  end

  # Do work
  def run
    if config[:tags] && config[:all]
      critical 'Cannot specify --tags and --all simultaneously (Consul health/service/ versus health/state/).'
    end

    Diplomat.configure do |dc|
      dc.url = config[:consul]
    end

    found      = false
    warnings   = false
    criticals  = false
    checks     = []

    # Process all of the nonpassing service checks
    acquire_service_data.each do |d|
      found       = true
      checkId     = d['CheckID'] # rubocop:disable Style/VariableName
      checkStatus = d['Status'] # rubocop:disable Style/VariableName

      # If we are passing do nothing
      next if checkStatus == 'passing'

      checks.push(
        checkId => d['Output'],
        'Status' => checkStatus
      )

      warnings  = true  if %w[warning].include? checkStatus
      criticals = true  if %w[critical unknown].include? checkStatus
    end

    if config[:fail_if_not_found] && !found
      msg = 'Could not find checks for any services'
      if config[:service]
        msg = "Could not find checks for service #{config[:service]}"
        if config[:tags]
          msg += " with tags #{config[:tags]}"
        end
      end
      critical msg
    end
    critical checks if criticals
    warning checks  if warnings
    ok
  end
end
