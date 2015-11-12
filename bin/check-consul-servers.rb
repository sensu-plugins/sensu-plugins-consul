#! /usr/bin/env ruby
#
#   check-consul-leader
#
# DESCRIPTION:
#   This plugin checks if consul is up and reachable. It then checks
#   the status/leader and ensures there is a current leader.
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
#   #YELLOW
#
# NOTES:
#
# LICENSE:
#   Copyright 2015 Sonian, Inc. and contributors. <support@sensuapp.org>
#   Released under the same terms as Sensu (the MIT license); see LICENSE
#   for details.
#

require 'sensu-plugin/check/cli'
require 'rest-client'
require 'json'

#
# Consul Status
#
class ConsulStatus < Sensu::Plugin::Check::CLI
  option :server,
         description: 'consul server',
         short: '-s SERVER',
         long: '--server SERVER',
         default: '127.0.0.1'

  option :port,
         description: 'consul http port',
         short: '-p PORT',
         long: '--port PORT',
         default: '8500'

  option :min,
         description: 'minimum number of peers',
         short: '-g GREATER THAN',
         long: '--greater GREATER THAN',
         default: 3

  option :expected,
         description: 'expected number of peers',
         short: '-e EXPECT',
         long: '--expect EXPECT',
         default: 5

  def run
    json = RestClient::Resource.new("http://#{config[:server]}:#{config[:port]}/v1/status/peers", timeout: 5).get
    peers = JSON.parse(json).length.to_i
    if peers < config[:min].to_i
      critical "[#{peers}] peers is below critical threshold of [#{config[:min]}]"
    elsif peers != config[:expected].to_i
      warning "[#{peers}] peers is outside of expected count of [#{config[:expected]}]"
    else
      ok 'Peers within threshold'
    end
  rescue Errno::ECONNREFUSED
    critical 'Consul is not responding'
  rescue RestClient::RequestTimeout
    critical 'Consul Connection timed out'
  rescue RestClient::Exception => e
    unknown "Consul returned: #{e}"
  end
end
