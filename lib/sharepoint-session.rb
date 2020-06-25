require 'erb'
require 'curb'

module Sharepoint
  MICROSOFT_STS_URL = "https://login.microsoftonline.com/extSTS.srf"

  module Soap
    class Authenticate
      SOURCE = "soap/authenticate.xml.erb"

      attr_accessor :username, :password, :login_url

      def self.initialize
        return if @initialized == true
        @erb          = ERB.new(::File.read ::File.dirname(__FILE__) + '/' + SOURCE)
        @erb.filename = SOURCE
        @erb.def_method self, 'render()'
        @initialized  = true
      end

      def initialize params = {}
        Authenticate.initialize
        @username  = params[:username]
        @password  = params[:password]
        @login_url = params[:url]
      end
    end
  end

  class Session
    class Error < Sharepoint::Error; end
    class ConnexionToStsFailed        < Sharepoint::Session::Error; end
    class ConnexionToSharepointFailed < Sharepoint::Session::Error; end
    class UnknownAuthenticationError  < Sharepoint::Session::Error; end
    class AuthenticationFailed        < Sharepoint::Session::Error; end

    attr_accessor :site

    def initialize site
      @site = site
    end

    def authenticate user, password, sts_url = nil
      sts_url ||= MICROSOFT_STS_URL
      authenticate_to_sts user, password, sts_url
      get_access_token
    end

    def cookie
      "FedAuth=#{@fed_auth};rtFa=#{@rtFa}"
    end

  private
    def authenticate_to_sts user, password, sts_url
      query    = Soap::Authenticate.new username: user, password: password, url: @site.authentication_path
      response = Curl::Easy.http_post sts_url, query.render rescue raise ConnexionToStsFailed.new

      response.body_str.scan(/<wsse:BinarySecurityToken[^>]*>([^<]+)</) do
        offset          = ($~.offset 1)
        @security_token = response.body[offset[0]..offset[1] - 1]
      end
      authentication_failed response.body_str if @security_token.nil?
    end

    def get_cookie_from_header header, cookie_name
      result = nil
      header.scan(/#{cookie_name}=([^;]+);/) do
        offset = $~.offset 1
        result = header[offset[0]..offset[1] - 1]
      end
      result
    end

    def get_access_token
      http = Curl::Easy.http_post @site.authentication_path, @security_token
      @rtFa     = get_cookie_from_header http.header_str, 'rtFa'
      @fed_auth = get_cookie_from_header http.header_str, 'FedAuth'
      raise UnknownAuthenticationError.new if @fed_auth.nil? or @rtFa.nil?
    end

    def authentication_failed xml
      message   = 'Unknown authentication error'
      xml.scan(/<psf:text[^>]*>([^<]+)</) do
        offset  = ($~.offset 1)
        message = xml[offset[0]..offset[1] - 1]
      end
      raise AuthenticationFailed.new message
    end
  end
end

