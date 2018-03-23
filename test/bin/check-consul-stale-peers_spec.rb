# frozen_string_literal: true

#
# check-consul-stale-peers_spec
#
# DESCRIPTION:
#   Tests for check-consul-stale-peers.rb
#
# OUTPUT:
#
# PLATFORMS:
#
# DEPENDENCIES:
#
# USAGE:
#   bundle install
#   rake spec
#
# NOTES:
#
# LICENSE:
#   Copyright 2018, Jonathan Hartman <j@hartman.io>
#   Released under the same terms as Sensu (the MIT license); see LICENSE
#   for details.
#

require_relative '../spec_helper.rb'
require_relative '../../bin/check-consul-stale-peers.rb'

describe ConsulStalePeers do
  let(:config) { [] }
  let(:check) { described_class.new(config) }

  describe '#run' do
    let(:raft) { nil }

    before do
      expect(check).to receive(:consul_get).with('operator/raft/configuration')
                                           .and_return(raft)
    end

    context 'a healthy cluster' do
      let(:raft) do
        {
          'Servers' => [
            {
              'ID' => '1.2.3.4:8300',
              'Node' => 'ip-1-2-3-4',
              'Address' => '1.2.3.4:8300',
              'Leader' => false,
              'Voter' => true
            },
            {
              'ID' => '1.2.3.5:8300',
              'Node' => 'ip-1-2-3-5',
              'Address' => '1.2.3.5:8300',
              'Leader' => false,
              'Voter' => true
            },
            {
              'ID' => '1.2.3.6:8300',
              'Node' => 'ip-1-2-3-6',
              'Address' => '1.2.3.6:8300',
              'Leader' => true,
              'Voter' => true
            }
          ]
        }
      end

      context 'a default config' do
        it 'returns an ok' do
          expect(check.run).to eq('OK: Cluster contains 0 stale peers')
        end
      end
    end

    context 'a cluster with a stale peer' do
      let(:raft) do
        {
          'Servers' => [
            {
              'ID' => '1.2.3.4:8300',
              'Node' => 'ip-1-2-3-4',
              'Address' => '1.2.3.4:8300',
              'Leader' => false,
              'Voter' => true
            },
            {
              'ID' => '1.2.3.5:8300',
              'Node' => 'ip-1-2-3-5',
              'Address' => '1.2.3.5:8300',
              'Leader' => false,
              'Voter' => true
            },
            {
              'ID' => '1.2.3.6:8300',
              'Node' => 'ip-1-2-3-6',
              'Address' => '1.2.3.6:8300',
              'Leader' => true,
              'Voter' => true
            },
            {
              'ID' => 'blargh',
              'Node' => '(unknown)',
              'Address' => '1.2.3.6:8300',
              'Leader' => false,
              'Voter' => true
            }
          ]
        }
      end

      context 'a default config' do
        it 'returns a critical' do
          expect(check.run).to eq('CRITICAL: Cluster contains 1 stale peer')
        end
      end

      context 'a config to return warning at one stale peer' do
        let(:config) { %w[-C 2] }

        it 'returns a warning' do
          expect(check.run).to eq('WARNING: Cluster contains 1 stale peer')
        end
      end

      context 'a config to return ok at one stale peer' do
        let(:config) { %w[-W 2 -C 3] }

        it 'returns an ok' do
          expect(check.run).to eq('OK: Cluster contains 1 stale peer')
        end
      end
    end
  end
end
