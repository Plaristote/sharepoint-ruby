require 'curb'
require 'json'
require 'sharepoint-session'
require 'sharepoint-object'
require 'sharepoint-types'

module Sharepoint
  class SPException < Exception
    def initialize data
      @data = data['error']
    end

    def lang    ; @data['message']['lang']  ; end
    def message ; @data['message']['value'] ; end
    def code    ; @data['code'] ; end
  end

  class Site
    attr_accessor :url
    attr_accessor :session
    attr_accessor :name

    def initialize server_url, site_name
      @server_url  = server_url
      @name        = site_name
      @url         = "#{@server_url}/#{@name}"
      @session     = Session.new self
      @web_context = nil
    end

    def authentication_path
      "https://#{@server_url}/_forms/default.aspx?wa=wsignin1.0"
    end

    def api_path
      "https://#{@url}/_api/web/"
    end

    def form_digest
      if @web_context.nil? or (not @web_context.is_up_to_date?)
        @getting_form_digest = true
        @web_context         = query :post, "https://#{@url}/_api/contextinfo"
        @getting_form_digest = false
      end
      @web_context.form_digest_value
    end

    def query method, uri, body = nil, &block
      uri        = if uri =~ /^http/ then uri else api_path + uri end
      arguments  = [ uri ]
      arguments << body if method != :get
      #puts "Querrying #{uri}"
      #puts "With body: " + body if method != :get and not body.nil?
      result = Curl::Easy.send "http_#{method}", *arguments do |curl|
        curl.headers["Cookie"]          = @session.cookie
        curl.headers["Accept"]          = "application/json;odata=verbose"
        if method != :get
          curl.headers["Content-Type"]    = curl.headers["Accept"]
          curl.headers["X-RequestDigest"] = form_digest unless @getting_form_digest == true
        end
        curl.verbose = false
        block.call curl unless block.nil?
      end

      begin
        data = JSON.parse result.body_str
        raise Sharepoint::SPException.new data unless data['error'].nil?
        make_object_from_response data
      rescue JSON::ParserError => e
        result.body_str
      end
    end

    def make_object_from_response data
      if data['d']['results'].nil?
        data['d'] = data['d'][data['d'].keys.first] if data['d']['__metadata'].nil?
        make_object_from_data data['d']
      else
        array = Array.new
        data['d']['results'].each do |result|
          array << (make_object_from_data result)
        end
        array
      end
    end

    def make_object_from_data data
      type_name = data['__metadata']['type'].gsub /^SP\./, ''
      klass     = Sharepoint.const_get type_name rescue raise UnsupportedType.new type_name
      klass.new self, data
    end
  end
end

