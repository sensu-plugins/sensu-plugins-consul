# frozen_string_literal: true

#
#   sensu-plugins-consul/check/base_spec
#
# DESCRIPTION:
#   Tests for SensuPluginsConsul::Check::Base
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

require_relative '../../../spec_helper.rb'
require_relative '../../../../lib/sensu-plugins-consul/check/base'

describe SensuPluginsConsul::Check::Base do
  let(:config) { [] }
  let(:check) { described_class.new(config) }

  describe '#consul_get' do
    context 'a default config' do
      before do
        expect(RestClient::Resource).to receive(:new)
          .with('http://127.0.0.1:8500/v1/things',
                timeout: 5,
                verify_ssl: true,
                ssl_ca_file: nil,
                headers: { 'X-Consul-Token' => nil })
          .and_return(double(get: '{"some":"json"}'))
      end

      it 'fetches the appropriate URL' do
        expect(check.consul_get('things')).to eq('some' => 'json')
      end
    end

    context 'a custom HTTPS config' do
      let(:config) { %w[-s 1.2.3.4 -P https -p 4443 -c /etc/ca --insecure] }

      before do
        expect(RestClient::Resource).to receive(:new)
          .with('https://1.2.3.4:4443/v1/things',
                timeout: 5,
                verify_ssl: false,
                ssl_ca_file: '/etc/ca',
                headers: { 'X-Consul-Token' => nil })
          .and_return(double(get: '{"some":"json"}'))
      end

      it 'fetches the appropriate URL' do
        expect(check.consul_get('things')).to eq('some' => 'json')
      end
    end

    context 'a connection refused error' do
      before do
        expect(RestClient::Resource).to receive(:new)
          .and_raise(Errno::ECONNREFUSED)
      end

      it 'returns a critical' do
        res = check.consul_get('/things')
        expect(res).to eq('CRITICAL: Consul is not responding')
      end
    end

    context 'a request timeout error' do
      before do
        expect(RestClient::Resource).to receive(:new)
          .and_raise(RestClient::RequestTimeout)
      end

      it 'returns a critical' do
        res = check.consul_get('/things')
        expect(res).to eq('CRITICAL: Consul connection timed out')
      end
    end

    context 'some other REST exception' do
      before do
        expect(RestClient::Resource).to receive(:new)
          .and_raise(RestClient::Exception)
      end

      it 'returns a critical' do
        res = check.consul_get('/things')
        expect(res).to eq('UNKNOWN: Consul returned: RestClient::Exception: ')
      end
    end
  end
end
