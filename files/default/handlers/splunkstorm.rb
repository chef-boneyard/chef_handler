#!/usr/bin/env ruby
# Chef Exception Handler for Splunk Storm.

require 'rubygems'
require 'json'
require 'rest-client'


module SplunkStorm
  # Chef Exception Handler for Splunk Storm.
  #
  # Extracts several keys from the run_status Hash, converts them to JSON, and
  # POSTs them to Splunk Storm as an event for later searching & reporting.
  #
  # = Usage
  # 1. Create a Splunk Storm account: https://www.splunkstorm.com
  # 2. Retrieve your Access Token & Project ID: http://docs.splunk.com/Documentation/Storm/latest/User/UseStormsRESTAPI
  # 3. Add the chef_handler Cookbook to your Run List.
  # 4. Add a chef_handler Resource to one of your existing Recipes.
  #
  # = Example
  # Here's an example +chef_handler+ Resource given you've retrieved your
  # Access Token as *ACCESS_TOKEN* and Project ID as *PROJECT_ID*:
  #
  #   chef_handler 'SplunkStorm::SplunkStormHandler' do
  #     action :enable
  #     source File.join(node['chef_handler']['handler_path'],
  #       'splunkstorm.rb')
  #     arguments ['ACCESS_TOKEN', 'PROJECT_ID']
  #   end
  #
  # = Requirements
  # * +json+ Gem: http://flori.github.com/json/
  # * +rest-client+ Gem: https://github.com/archiloque/rest-client
  # 
  # = Links
  # * Internal Splunk JIRA: http://jira.splunk.com/browse/STORM-3796
  # * Opscode JIRA: http://tickets.opscode.com/browse/COOK-1208
  #
  # Author:: Greg Albrecht <mailto:gba@splunk.com>
  # Copyright:: Copyright 2012 Splunk, Inc.
  # License:: Apache License 2.0.
  #
  class SplunkStormHandler < Chef::Handler
    SPLUNKSTORM_URL = 'https://api.splunkstorm.com'
    API_ENDPOINT = '/1/inputs/http'

    #
    #
    # * *Args*:
    #   - +access_token+ -> A Splunk Storm Access Token.
    #   - +project_id+ -> A Splunk Storm Project ID.
    #
    def initialize(access_token, project_id)
      @access_token = access_token
      @project_id = project_id
    end

    # Reports Chef's +run_status+ metrics and results to Splunk Storm.
    def report_metrics
      event_metadata = {
        :sourcetype => 'generic_single_line',
        :host => node.hostname,
        :project => @project_id}

      # We're creating a new Hash b/c 'node' and 'all_resources' in run_status
      # are just TOO large.
      status_event = {
        :failed => run_status.failed?,
        :start_time => run_status.start_time,
        :end_time => run_status.end_time,
        :elapsed_time => run_status.elapsed_time,
        :exception => run_status.formatted_exception}

      api_params = event_metadata.collect{ |k,v| [k, v].join('=') }.join('&')
      url_params = URI.escape(api_params)
      endpoint_path = [API_ENDPOINT, url_params].join('?')

      request = RestClient::Resource.new(
        SPLUNKSTORM_URL, :user => @access_token, :password => 'x')

      request[endpoint_path].post(status_event.to_json)
    end

    # Reports Chef's +run_status+ exception and backtrace to Splunk Storm.
    def report_exception
      event_metadata = {
        :sourcetype => 'storm_multi_line',
        :host => node.hostname,
        :project => @project_id}

      api_params = event_metadata.collect{ |k,v| [k, v].join('=') }.join('&')
      url_params = URI.escape(api_params)
      endpoint_path = [API_ENDPOINT, url_params].join('?')

      request = RestClient::Resource.new(
        SPLUNKSTORM_URL, :user => @access_token, :password => 'x')

      request[endpoint_path].post(Array(run_status.backtrace).join("\n"))
    end

    # Proxies calls for +report_metrics+ and, on failure, +report_exception+.
    def report
      report_metrics
      if run_status.failed?
        report_exception
      end
    end
  end
end
