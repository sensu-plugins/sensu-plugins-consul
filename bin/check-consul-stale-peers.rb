#! /usr/bin/env ruby
# frozen_string_literal: false

#
#   check-consul-stale-peers
#
# DESCRIPTION:
#   This plugin checks the raft configuration for stale ("unknown") peers.
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
#   Connect to localhost, go critical when there are any stale peers:
#     ./check-consul-stale-peers
#
#   Connect to a remote Consul server over HTTPS:
#     ./check-consul-stale-peers -s 192.168.42.42 -p 4443 -P https
#
#   Go critical when the cluster has two or more stale peers:
#     ./check-consul-stale-peers -W 1 -C 2
#
# NOTES:
#
# LICENSE:
#   Copyright 2018, Jonathan Hartman <j@hartman.io>
#   Released under the same terms as Sensu (the MIT license); see LICENSE
#   for details.
#

require 'sensu-plugins-consul/check/base'

#
# Consul stale peers
#
class ConsulStalePeers < SensuPluginsConsul::Check::Base
  option :warning,
         description: 'Warn when there are this many stale peers',
         short: '-W NUMBER_OF_PEERS',
         long: '--warning NUMBER_OF_PEERS',
         proc: proc(&:to_i),
         default: 1

  option :critical,
         description: 'Go critical when there are this many stale peers',
         short: '-C NUMBER_OF_PEERS',
         long: '--critical NUMBER_OF_PEERS',
         proc: proc(&:to_i),
         default: 1

  def run
    raft = consul_get('operator/raft/configuration')

    res = raft['Servers'].select { |s| s['Node'] == '(unknown)' }.length

    msg = "Cluster contains #{res} stale peer#{'s' unless res == 1}"

    if res >= config[:critical]
      critical msg
    elsif res >= config[:warning]
      warning msg
    else
      ok msg
    end
  end
end
