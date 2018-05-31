# frozen_string_literal: false

#
#   sensu-plugins-consul/check/base
#
# DESCRIPTION:
#   This class defines some of the common config options and helper methods for
#   other Consul plugins to use.
#
# OUTPUT:
#   N/A
#
# PLATFORMS:
#   Linux
#
# DEPENDENCIES:
#   gem: sensu-plugin
#   gem: rest-client
#
# USAGE:
#   Import this file and create subclasses of the included plugin class.
#     require 'sensu-plugins-consul/check/base'
#     class ConsulTestStatus < SensuPluginsConsul::Check::Base
#       ...
#
# NOTES:
#
# LICENSE:
#   Copyright 2018, Jonathan Hartman <j@hartman.io>
#   Released under the same terms as Sensu (the MIT license); see LICENSE
#   for details.
#

require 'json'
require 'rest-client'
require 'sensu-plugin/check/cli'

#
# Consul shared base plugin
#
module SensuPluginsConsul
  class Check
    class Base < Sensu::Plugin::Check::CLI
      option :server,
             description: 'Consul server',
             short: '-s SERVER',
             long: '--server SERVER',
             default: '127.0.0.1'

      option :port,
             description: 'Consul HTTP port',
             short: '-p PORT',
             long: '--port PORT',
             proc: proc(&:to_i),
             default: 8500

      option :protocol,
             description: 'Consul listener protocol',
             short: '-P PROTOCOL',
             long: '--protocol PROTOCOL',
             in: %w[http https],
             default: 'http'

      option :insecure,
             description: 'Set this flag to disable SSL verification',
             short: '-k',
             long: '--insecure',
             boolean: true,
             default: false

      option :capath,
             description: 'Absolute path to an alternative CA file',
             short: '-c CAPATH',
             long: '--capath CAPATH'

      option :timeout,
             description: 'Connection will time out after this many seconds',
             short: '-t TIMEOUT_IN_SECONDS',
             long: '--timeout TIMEOUT_IN_SECONDS',
             proc: proc(&:to_i),
             default: 5

      option :token,
             description: 'ACL token',
             long: '--token ACL_TOKEN',

      #
      # Fetch and return the parsed JSON data from a specified Consul API endpoint.
      #
      def consul_get(endpoint)
        url = "#{config[:protocol]}://#{config[:server]}:#{config[:port]}/" \
              "v1/#{endpoint}"
        options = { timeout: config[:timeout],
                    verify_ssl: !config[:insecure],
                    ssl_ca_file: config[:capath],
                    headers: { 'X-Consul-Token' => config[:token] }
                  }

        JSON.parse(RestClient::Resource.new(url, options).get)
      rescue Errno::ECONNREFUSED
        critical 'Consul is not responding'
      rescue RestClient::RequestTimeout
        critical 'Consul connection timed out'
      rescue RestClient::Exception => e
        unknown "Consul returned: #{e}"
      end
    end
  end
end
