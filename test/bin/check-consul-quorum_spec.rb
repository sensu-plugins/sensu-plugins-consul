# frozen_string_literal: true

#
# check-consul-quorum_spec
#
# DESCRIPTION:
#   Tests for check-consul-quorum.rb
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
require_relative '../../bin/check-consul-quorum.rb'

describe ConsulQuorumStatus do
  let(:config) { [] }
  let(:check) { described_class.new(config) }

  describe '#run' do
    let(:raft) { nil }
    let(:members) { nil }

    before do
      expect(check).to receive(:consul_get).with('operator/raft/configuration')
                                           .and_return(raft)
      expect(check).to receive(:consul_get).with('agent/members')
                                           .and_return(members)
    end

    context 'a 3/3 healthy cluster' do
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
      let(:members) do
        [
          {
            'Name' => 'ip-1-2-3-4',
            'Addr' => '1.2.3.4',
            'Port' => 8301,
            'Tags' => {
              'dc' => 'testing',
              'port' => '8300',
              'role' => 'consul'
            },
            'Status' => 1
          },
          {
            'Name' => 'ip-1-2-3-5',
            'Addr' => '1.2.3.5',
            'Port' => 8301,
            'Tags' => { 'role' => 'consul' },
            'Status' => 1
          },
          {
            'Name' => 'ip-1-2-3-6',
            'Addr' => '1.2.3.6',
            'Port' => 8301,
            'Tags' => { 'role' => 'consul' },
            'Status' => 1
          },
          {
            'Name' => 'ip-1-2-3-44',
            'Addr' => '1.2.3.44',
            'Port' => 8301,
            'Tags' => { 'role' => 'node' },
            'Status' => 1
          }
        ]
      end

      context 'a default config' do
        it 'returns a warning' do
          expect(check.run).to eq('WARNING: Cluster has 3/3 servers alive ' \
                                  'and can lose 1 more without losing quorum')
        end
      end

      context 'a config to return critical at one spare' do
        let(:config) { %w[-C 1] }

        it 'returns a critical' do
          expect(check.run).to eq('CRITICAL: Cluster has 3/3 servers alive ' \
                                  'and can lose 1 more without losing quorum')
        end
      end

      context 'a config to return ok at one spare' do
        let(:config) { %w[-W 0 -C 0] }

        it 'returns an ok' do
          expect(check.run).to eq('OK: Cluster has 3/3 servers alive ' \
                                  'and can lose 1 more without losing quorum')
        end
      end
    end

    context 'a 2/3 degraded cluster' do
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
      let(:members) do
        [
          {
            'Name' => 'ip-1-2-3-4',
            'Addr' => '1.2.3.4',
            'Port' => 8301,
            'Tags' => {
              'dc' => 'testing',
              'port' => '8300',
              'role' => 'consul'
            },
            'Status' => 4
          },
          {
            'Name' => 'ip-1-2-3-5',
            'Addr' => '1.2.3.5',
            'Port' => 8301,
            'Tags' => { 'role' => 'consul' },
            'Status' => 1
          },
          {
            'Name' => 'ip-1-2-3-6',
            'Addr' => '1.2.3.6',
            'Port' => 8301,
            'Tags' => { 'role' => 'consul' },
            'Status' => 1
          },
          {
            'Name' => 'ip-1-2-3-44',
            'Addr' => '1.2.3.44',
            'Port' => 8301,
            'Tags' => { 'role' => 'node' },
            'Status' => 1
          }
        ]
      end

      context 'a default config' do
        it 'returns a critical' do
          expect(check.run).to eq('CRITICAL: Cluster has 2/3 servers alive ' \
                                  'and has the minimum required for quorum')
        end
      end

      context 'a config to return warning at no spares' do
        let(:config) { %w[-W 0 -C -1] }

        it 'returns a warning' do
          expect(check.run).to eq('WARNING: Cluster has 2/3 servers alive ' \
                                  'and has the minimum required for quorum')
        end
      end

      context 'a config to return ok at no spares' do
        let(:config) { %w[-W -1 -C -1] }

        it 'returns an ok' do
          expect(check.run).to eq('OK: Cluster has 2/3 servers alive ' \
                                  'and has the minimum required for quorum')
        end
      end
    end

    context 'a 1/3 failed cluster' do
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
              'Leader' => false,
              'Voter' => true
            }
          ]
        }
      end
      let(:members) do
        [
          {
            'Name' => 'ip-1-2-3-4',
            'Addr' => '1.2.3.4',
            'Port' => 8301,
            'Tags' => {
              'dc' => 'testing',
              'port' => '8300',
              'role' => 'consul'
            },
            'Status' => 4
          },
          {
            'Name' => 'ip-1-2-3-5',
            'Addr' => '1.2.3.5',
            'Port' => 8301,
            'Tags' => { 'role' => 'consul' },
            'Status' => 4
          },
          {
            'Name' => 'ip-1-2-3-6',
            'Addr' => '1.2.3.6',
            'Port' => 8301,
            'Tags' => { 'role' => 'consul' },
            'Status' => 1
          },
          {
            'Name' => 'ip-1-2-3-44',
            'Addr' => '1.2.3.44',
            'Port' => 8301,
            'Tags' => { 'role' => 'node' },
            'Status' => 1
          }
        ]
      end

      context 'a default config' do
        it 'returns a critical' do
          expect(check.run).to eq('CRITICAL: Cluster has 1/3 servers alive ' \
                                  'and has lost quorum')
        end
      end

      context 'a config to return warning at -1 spares' do
        let(:config) { %w[-W -1 -C -2] }

        it 'returns a critical' do
          expect(check.run).to eq('CRITICAL: Cluster has 1/3 servers alive ' \
                                  'and has lost quorum')
        end
      end

      context 'a config to return ok at -1 spares' do
        let(:config) { %w[-W -2 -C -3] }

        it 'returns a critical' do
          expect(check.run).to eq('CRITICAL: Cluster has 1/3 servers alive ' \
                                  'and has lost quorum')
        end
      end
    end
  end
end
