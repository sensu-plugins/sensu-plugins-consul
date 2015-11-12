#! /usr/bin/env ruby
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
# Consul returns the numerical values for consul members state, which the
# numbers used are defined in : https://github.com/hashicorp/serf/blob/master/serf/serf.go
#
# StatusNone MemberStatus = iota  (0, "none")
# StatusAlive                     (1, "alive")
# StatusLeaving                   (2, "leaving")
# StatusLeft                      (3, "left")
# StatusFailed                    (4, "failed")
#

require 'sensu-plugin/check/cli'
require 'rest-client'
require 'json'

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

  def run
    r = RestClient::Resource.new("http://#{config[:server]}:#{config[:port]}/v1/agent/members", timeout: 5).get
    if r.code == 200
      failing_nodes = JSON.parse(r).find_all { |node| node['Status'] == 4 }
      if !failing_nodes.nil? && !failing_nodes.empty?
        failing_nodes.each_entry do |node|
          puts "Name: #{node['Name']}"
          RestClient::Resource.new("http://#{config[:server]}:#{config[:port]}/v1/agent/force-leave/#{node['Name']}", timeout: 5).get
        end
        ok 'Removed failed consul nodes'
      else
        ok 'No consul nodes to remove'
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
