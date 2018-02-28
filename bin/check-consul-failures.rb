#! /usr/bin/env ruby
# frozen_string_literal: true

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

  option :scheme,
         description: 'consul listener scheme',
         short: '-S SCHEME',
         long: '--scheme SCHEME',
         default: 'http'

  option :keep_failures,
         description: 'do not remove failing nodes',
         short: '-k',
         long: '--keep-failures',
         boolean: true,
         default: false

  option :critical,
         description: 'set state to critical',
         short: '-c',
         long: '--critical',
         boolean: true,
         default: false

  def run
    r = RestClient::Resource.new("#{config[:scheme]}://#{config[:server]}:#{config[:port]}/v1/agent/members", timeout: 5).get
    if r.code == 200
      failing_nodes = JSON.parse(r).find_all { |node| node['Status'] == 4 }
      if !failing_nodes.nil? && !failing_nodes.empty?
        nodes_names = []
        failing_nodes.each_entry do |node|
          nodes_names.push(node['Name'])
          next if config[:keep_failures]
          puts "Removing failed node: #{node['Name']}"
          RestClient::Resource.new("#{config[:scheme]}://#{config[:server]}:#{config[:port]}/v1/agent/force-leave/#{node['Name']}", timeout: 5).get
          nodes_names.delete(node['Name'])
        end
        ok 'All clear' if nodes_names.empty?
        critical "Found failed nodes: #{nodes_names}" if config[:critical]
        warning "Found failed nodes: #{nodes_names}"
      else
        ok 'All nodes are alive'
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
