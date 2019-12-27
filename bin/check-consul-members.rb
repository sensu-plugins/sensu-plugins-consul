#! /usr/bin/env ruby
# frozen_string_literal: true

#
#   check-consul-members
#
# DESCRIPTION:
#   This plugin checks if consul is up and reachable. It then checks
#   the status of the members of the cluster to determine if the correct
#   number of peers are reporting as 'alive'
#
# OUTPUT:
#   plain text
#
# PLATFORMS:
#   Linux
#
# DEPENDENCIES:
#   gem: sensu-plugin
#   gem: rest-client
#   gem: json
#
# USAGE:
#   Check to make sure the min number of peers needed is present in the cluster
#   ./check-consul-members -s 127.0.0.1 -p 8500 -g 5 -e 8
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

  option :wan,
         description: 'whether to check the wan members',
         short: '-w',
         long: '--wan',
         boolean: false

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
         description: 'ACL token',
         long: '--token ACL_TOKEN'

  def run
    url = "#{config[:scheme]}://#{config[:server]}:#{config[:port]}/v1/agent/members"
    options = { timeout: config[:timeout],
                verify_ssl: (OpenSSL::SSL::VERIFY_NONE if defined? config[:insecure]),
                ssl_ca_file: (config[:capath] if defined? config[:capath]),
                headers: { 'X-Consul-Token' => config[:token] } }

    if config[:wan]
      url += '?wan=1'
    end

    json = RestClient::Resource.new(url, options).get
    peers = 0
    members = JSON.parse(json)
    members.each do |member|
      # only count the member if its status is alive
      if member.key?('Tags') && member['Tags']['role'] == 'consul' && member['Status'] == 1
        peers += 1
      end
    end

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
