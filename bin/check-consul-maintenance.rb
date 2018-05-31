#! /usr/bin/env ruby
# frozen_string_literal: true

#
#   check-consul-maintenance
#
# DESCRIPTION:
#   This plugin checks if maintenance mode is enabled
#   for the node in Consul
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
#   ./check-consul-maintenance -n localhost
#
# NOTES:
#
# LICENSE:
#   Copyright 2016 Oleksandr Kushchenko <gearok@gmail.com>
#   Released under the same terms as Sensu (the MIT license); see LICENSE
#   for details.
#

require 'sensu-plugin/check/cli'
require 'diplomat'

#
# Maintenance Status
#
class MaintenanceStatus < Sensu::Plugin::Check::CLI
  option :consul,
         description: 'consul server',
         long: '--consul SERVER',
         default: 'http://localhost:8500'

  option :node,
         description: 'consul node name',
         short: '-n NODE',
         long: '--node NODE',
         default: 'localhost'

  option :token,
         description: 'ACL token',
         long: '--token ACL_TOKEN'

  # Get the maintenance data for the node from consul
  #
  def acquire_maintenance_data
    result = Diplomat::Health.node(config[:node]).select do |check|
      check['CheckID'] == '_node_maintenance'
    end
    if !result.empty?
      { enabled: true, reason: result.first['Notes'] }
    else
      { enabled: false, reason: nil }
    end
  rescue Faraday::ConnectionFailed => e
    warning "Connection error occurred: #{e}"
  rescue Faraday::ClientError => e
    if e.response[:status] == 403
      critical %(ACL token is not authorized to access resource: #{e.response[:body]})
    else
      unknown "Exception occurred when checking consul service: #{e}"
    end
  rescue StandardError => e
    unknown "Exception occurred when checking consul node maintenance: #{e}"
  end

  # Main function
  #
  def run
    Diplomat.configure do |dc|
      dc.url = config[:consul]
      dc.acl_token = config[:token]
      dc.options = {
        headers: {
          'X-Consul-Token' => config[:token]
        }
      }
    end

    data = acquire_maintenance_data

    if data[:enabled]
      critical "Maintenance enabled for node #{config[:node]}: #{data[:reason]}"
    else
      ok "Maintenance disabled for node #{config[:node]}"
    end
  end
end
