#! /usr/bin/env ruby
# frozen_string_literal: true

#
#   check-consul-kv-ttl
#
# DESCRIPTION:
#   This plugin assists in checking a Consul KV namespace for timed out global operations
#
# OUTPUT:
#   plain text
#
# PLATFORMS:
#   Linux
#
# DEPENDENCIES:
#   gem: sensu-plugin
#   gem: diplomat
#
# USAGE:
#   ./check-consul-kv-ttl -kv 'ttl/service/tag' -w 30 -c 60
#   ./check-consul-kv-ttl -kv 'ttl/service/tag' -w 30 -c 60 -j -t 'date'
#   ./check-consul-kv-ttl -kv 'ttl/service/tag' -w 30 -c 60 -j -t 'date' -s 'status'
#
# NOTES:
#
# LICENSE:
#   Copyright 2015 Yieldbot, Inc. <devops@yieldbot.com>
#   Released under the same terms as Sensu (the MIT license); see LICENSE
#   for details.
#

require 'sensu-plugin/check/cli'
require 'diplomat'
require 'json'
require 'time'

class Hash
  def dig(dotted_path)
    parts = dotted_path.split '.', 2
    match = self[parts[0]]
    if !parts[1] || match.nil? # rubocop:disable Style/GuardClause
      return match
    else
      return match.dig(parts[1])
    end
  end
end

#
# Service Status
#
class CheckConsulKvTTL < Sensu::Plugin::Check::CLI
  option :consul,
         description: 'consul server',
         long: '--consul SERVER',
         default: 'http://localhost:8500'

  option :kv,
         description: 'kv namespace to pull data from',
         short: '-k NAMESPACE',
         long: '--kv NAMESPACE',
         default: nil,
         required: true

  option :json,
         description: 'Process the value as JSON',
         short: '-j',
         long: '--json',
         default: true

  option :timestamp_key,
         description: 'Use the given dotted path to alert based on the time(ISO8601), if processing as JSON',
         short: '-t PATH',
         long: '--timestamp PATH',
         default: nil

  option :status_key,
         description: 'Use the given dotted path to alert based on the status, if processing as JSON',
         short: '-s PATH',
         long: '--status PATH',
         default: nil

  option :warning,
         description: 'Warning TTL Threshold',
         short: '-w THRESHOLD',
         long: '--warning THRESHOLD',
         proc: proc { |a| a.to_i },
         default: 30

  option :critical,
         description: 'Critical TTL Threshold',
         short: '-c THRESHOLD',
         long: '--critical THRESHOLD',
         proc: proc { |a| a.to_i },
         default: 60

  # Do work
  def run
    Diplomat.configure do |dip|
      dip.url = config[:consul]
    end

    begin
      # Retrieve the kv
      data = Diplomat::Kv.get(config[:kv])
    rescue Faraday::ResourceNotFound
      critical "Key/Value(#{config[:kv]}) pair does not exist in Consul."
    rescue Exception => e # rubocop:disable Lint/RescueException
      critical "Unhandled exception(#{e.class}) -- #{e.message}"
    end

    # Check if the data is JSON or a timestamp
    if config[:json]
      begin
        # Convert the data to JSON
        json_data = JSON.parse(data)

        # If the status is set add that to the processing chain
        if config[:status_key]
          # Dig to the status
          kv_status = json_data.dig(config[:status_key])

          # Critical if we can not retrieve the status
          critical "Unable to retrieve status from JSON data: #{data}" if kv_status.nil?

          # Downcase to ease integration
          kv_status = kv_status.downcase

          # Flag based off of status
          warning 'Warning status detected!'    if %w[warning].include? kv_status
          critical 'Critical status detected!'  if %w[critical unknown].include? kv_status
        end

        # Dig to the time
        kv_time = json_data.dig(config[:timestamp_key])

        # Critical if we can not retrieve the time
        critical "Unable to retrieve time from JSON data: #{data}" if kv_time.nil?
      rescue JSON::ParserError => e # rubocop:disable Lint/UselessAssignment
        critical "Unable to parse JSON data: #{data}"
      end
    else
      kv_time = data
    end

    # Timestamp calculation
    begin
      # Convert the time into ISO8601 DateTime object
      start_time = Time.iso8601(kv_time)

      # Get the current time UTC
      end_time = Time.now.utc

      # Get diff in seconds between start and end time
      elapsed_seconds = (end_time - start_time).to_i

      critical "TTL calculation issue -- check date formats -- elapsed seconds is negative(#{elapsed_seconds})" if elapsed_seconds <= -1
      critical "TTL Expired! Elapsed Time: #{elapsed_seconds}"                if elapsed_seconds > config[:critical]
      warning  "TTL Expiration Approaching! Elapsed Time: #{elapsed_seconds}" if elapsed_seconds > config[:warning]
      ok
    rescue StandardError
      critical 'Unable to process DateTime objects!'
    end
  end
end
