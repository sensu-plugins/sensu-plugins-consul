# frozen_string_literal: true

require 'codeclimate-test-reporter'

RSpec.configure do |c|
  c.before do
    # Give Sensu's at_exit code something to run that's not a real plugin.
    Sensu::Plugin::CLI.class_eval do
      # PluginStub
      class PluginStub
        def run; end

        def ok(*); end

        def warning(*); end

        def critical(*); end

        def unknown(*); end
      end
      class_variable_set(:@@autorun, PluginStub)
    end

    # Stub every status method to return a string instead of exiting.
    %i[ok warning critical unknown].each do |status|
      allow_any_instance_of(Sensu::Plugin::CLI).to receive(status) do |_, val|
        "#{status.upcase}: #{val}"
      end
    end
  end
end

CodeClimate::TestReporter.start
