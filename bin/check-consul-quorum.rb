#! /usr/bin/env ruby
# frozen_string_literal: false

#
#   check-consul-quorum
#
# DESCRIPTION:
#   This plugin checks how many nodes the cluster will be able to lose while
#   still maintaining quorum.
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
#   Connect to localhost, go critical when the cluster is at its minimum for
#   quorum:
#     ./check-consul-quorum
#
#   Connect to a remote Consul server over HTTPS:
#     ./check-consul-quorum -s 192.168.42.42 -p 4443 -P https
#
#   Go critical when the cluster can lose one more server and keep quorum:
#     ./check-consul-quorum -W 2 -C 1
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
# Consul quorum status
#
class ConsulQuorumStatus < SensuPluginsConsul::Check::Base
  option :warning,
         description: 'Warn when the cluster has this many spare servers ' \
                      'beyond the minimum for quorum',
         short: '-W NUMBER_OF_SPARE_SERVERS',
         long: '--warning NUMBER_OF_SPARE_SERVERS',
         proc: proc(&:to_i),
         default: 1

  option :critical,
         description: 'Go critical when the cluster has this many spare ' \
                      'servers beyond the minimum for quorum',
         short: '-C NUMBER_OF_SPARE_SERVERS',
         long: '--critical NUMBER_OF_SPARE_SERVERS',
         proc: proc(&:to_i),
         default: 0

  def run
    raft = consul_get('operator/raft/configuration')
    members = consul_get('agent/members')

    total = raft['Servers'].select { |s| s['Voter'] == true }.length
    required = total / 2 + 1
    alive = members.select do |m|
      m.key?('Tags') && m['Tags']['role'] == 'consul' && m['Status'] == 1
    end.length

    spares = alive - required

    msg = "Cluster has #{alive}/#{total} servers alive and"
    msg = if spares < 0
            "#{msg} has lost quorum"
          elsif spares.zero?
            "#{msg} has the minimum required for quorum"
          else
            "#{msg} can lose #{spares} more without losing quorum"
          end

    if spares < 0 || spares <= config[:critical]
      critical msg
    elsif spares <= config[:warning]
      warning msg
    else
      ok msg
    end
  end
end
