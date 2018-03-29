#! /usr/bin/env ruby
# frozen_string_literal: true

#
#   check-consul-servers
#
# DESCRIPTION:
#   This plugin checks if consul is up and reachable. It then checks
#   the number of peers matches the excepted value
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
         proc: proc(&:to_i),
         default: 3

  option :expected,
         description: 'expected number of peers',
         short: '-e EXPECT',
         long: '--expect EXPECT',
         proc: proc(&:to_i),
         default: 5

  option :scheme,
         description: 'consul listener scheme',
         short: '-S SCHEME',
         long: '--scheme SCHEME',
         default: 'http'

  option :insecure,
         description: 'if set, disables SSL verification',
         short: '-k',
         long: '--insecure',
         boolean: true,
         default: false

  option :capath,
         description: 'absolute path to an alternate CA file',
         short: '-c CAPATH',
         long: '--capath CAPATH'

  option :timeout,
         description: 'connection will time out after this many seconds',
         short: '-t TIMEOUT_IN_SECONDS',
         long: '--timeout TIMEOUT_IN_SECONDS',
         proc: proc(&:to_i),
         default: 5

  option :token,
         description: 'set X-Consul-Token header http token',
         short: '-T',
         long: '--token CONSUL_TOKEN'

  def run
    url = "#{config[:scheme]}://#{config[:server]}:#{config[:port]}/v1/status/peers"
    options = { timeout: config[:timeout],
                verify_ssl: (OpenSSL::SSL::VERIFY_NONE if defined? config[:insecure]),
                headers: ({ 'X-Consul-Token' => config[:token] } if defined? config[:token]),
                ssl_ca_file: (config[:capath] if defined? config[:capath]) }

    json = RestClient::Resource.new(url, options).get
    peers = JSON.parse(json).length.to_i
    if peers < config[:min]
      critical "[#{peers}] peers is below critical threshold of [#{config[:min]}]"
    elsif peers != config[:expected]
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
