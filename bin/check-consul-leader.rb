#! /usr/bin/env ruby
# frozen_string_literal: true

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
#   gem: rest-client
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
require 'resolv'

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

  option :scheme,
         description: 'consul listener scheme',
         short: '-S SCHEME',
         long: '--scheme SCHEME',
         default: 'http'

  option :insecure,
         description: 'set this flag to disable SSL verification',
         short: '-k',
         long: '--insecure',
         boolean: true,
         default: false

  option :capath,
         description: 'absolute path to an alternative CA file',
         short: '-c CAPATH',
         long: '--capath CAPATH'

  option :timeout,
         description: 'connection will time out after this many seconds',
         short: '-t TIMEOUT_IN_SECONDS',
         long: '--timeout TIMEOUT_IN_SECONDS',
         default: 5

  def valid_ip(ip)
    case ip.to_s
    when Resolv::IPv4::Regex
      true
    when Resolv::IPv6::Regex
      true
    else
      false
    end
  end

  def strip_ip(str)
    ipv4_regex = '(([0-9]|[1-9][0-9]|1[0-9]{2}|2[0-4][0-9]|25[0-5])\.){3}([0-9]|[1-9][0-9]|1[0-9]{2}|2[0-4][0-9]|25[0-5])'
    ipv6_regex = '\[.*\]'
    if str =~ /^.*#{ipv4_regex}.*$/ # rubocop:disable Style/GuardClause
      return str.match(/#{ipv4_regex}/)
    elsif str =~ /^.*#{ipv6_regex}.*$/
      return str[/#{ipv6_regex}/][1..-2]
    else
      return str
    end
  end

  def run
    options = { timeout: config[:timeout],
                verify_ssl: (OpenSSL::SSL::VERIFY_NONE if defined? config[:insecure]),
                ssl_ca_file: (config[:capath] if defined? config[:capath]) }
    url = "#{config[:scheme]}://#{config[:server]}:#{config[:port]}/v1/status/leader"

    r = RestClient::Resource.new(url, options).get

    if r.code == 200
      if valid_ip(strip_ip(r.body))
        ok 'Consul is UP and has a leader'
      else
        critical 'Consul is UP, but it has NO leader'
      end
    else
      critical 'Consul is not responding'
    end
  rescue Errno::ECONNREFUSED
    critical 'Consul is not responding'
  rescue RestClient::RequestTimeout
    critical 'Consul Connection timed out'
  rescue RestClient::Exception => e
    unknown "Consul returned: #{e}"
  end
end
