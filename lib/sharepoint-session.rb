require 'erb'
require 'curb'

module Sharepoint
  STS_URL = "https://login.microsoftonline.com/extSTS.srf"

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
    class ConnexionToStsFailed ; end
    class AuthenticationFailed ; end
    class ConnexionToSharepointFailed ; end
    class UnknownAuthenticationError ; end

    attr_accessor :site

    def initialize site
      @site = site
    end

    def authenticate user, password
      authenticate_to_sts user, password
      get_access_token
    end

    def cookie
      "FedAuth=#{@fed_auth};rtFa=#{@rtFa}"
    end

  private
    def authenticate_to_sts user, password
      query    = Soap::Authenticate.new username: user, password: password, url: @site.authentication_path
      response = Curl::Easy.http_post STS_URL, query.render rescue raise ConnexionToStsFailed.new

      response.body_str.scan(/<wsse:BinarySecurityToken[^>]*>([^<]+)</) do
        offset          = ($~.offset 1)
        @security_token = response.body[offset[0]..offset[1] - 1]
      end
      raise AuthenticationFailed.new if @security_token.nil?
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
      raise ConnexionToSharepointFailed.new if http.perform != true
      @rtFa     = get_cookie_from_header http.header_str, 'rtFa'
      @fed_auth = get_cookie_from_header http.header_str, 'FedAuth'
      raise UnknownAuthenticationError.new if @fed_auth.nil? or @rtFa.nil?
    end
  end
end

