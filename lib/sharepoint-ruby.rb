require 'curb'
require 'json'
require 'sharepoint-session'
require 'sharepoint-object'

module Sharepoint
  class Site
    attr_accessor :url
    attr_accessor :session
    attr_accessor :name

    def initialize server_url, site_name
      @server_url = server_url
      @name       = site_name
      @url        = "#{@server_url}/#{@name}"
      @session    = Session.new self
    end

    def authentication_path
      "https://#{@server_url}/_forms/default.aspx?wa=wsignin1.0"
    end

    def api_path
      "https://#{@url}/_api/web/"
    end

    def query method, uri, &block
      result = Curl::Easy.send "http_#{method}", (api_path + uri) do |curl|
        curl.headers["Cookie"] = @session.cookie
        curl.headers["Accept"] = "application/json;odata=verbose"
        curl.verbose = true
        block.call curl unless block.nil?
      end
      puts result.body_str.inspect
      data = JSON.parse result.body_str
      make_object_from_response data
    end

    def make_object_from_response data
      if data['d']['results'].nil?
        Sharepoint::Object.new self, data['d']
      else
        array = Array.new
        data['d']['results'].each do |result|
          array << (Sharepoint::Object.new self, result)
        end
        array
      end
    end
  end
end

