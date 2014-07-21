require 'erb'
require 'curb'
require 'nokogiri'
require 'cgi'

module Sharepoint
  module Juniper
    class Session
      attr_accessor :site
      attr_accessor :juniper_url

      def initialize site
        @site = site
      end

      def update_site_behaviors_for_juniper
        class << @site
          define_method :api_path, proc { |uri|
            "#{@session.juniper_url}/_api/web/#{uri}/,DanaInfo=#{@server_url},Port=#{38883}"
          }
        end
      end

      def authenticate user, password, domain, juniper_url
        @juniper_url = juniper_url
        authenticate_to_juniper user, password, domain
        update_site_behaviors_for_juniper
      end

      def cookie
        "DSID=#{@dsid}"
      end

    private
      def login_url
        "#{@juniper_url}/dana-na/auth/url_default/login.cgi"
      end

      def ensure_sharepoint_initialization user, password, domain
        query_url = "#{@juniper_url}/,DanaInfo=#{@site.server_url},Port=38883,SSO=U+"
        response  = Curl::Easy.http_post query_url do |curl|
          curl.headers["Cookie"] = cookie
          curl.follow_location   = true
        end

        if response.header_str.include? 'MicrosoftSharePointTeamServices'
          puts '[Juniper] Sharepoint already set up'
        else
          doc    = Nokogiri::HTML response.body_str
          xsauth = (doc.xpath '//input[@name="xsauth"]/@value').first.value
          puts "xsauth = #{xsauth}"
          params = {
            xsauth:     xsauth,
            username:   user,
            password:   password,
            domain:     'MPF',
            userDomain: domain,
            proxy:      0,
            host:       site.server_url,
            url:        "/,DanaInfo=#{@site.server_url},Port=38883,SSO=U%2B",
            DANAmethod: nil,
            DANAmvalue: nil,
            proxyhost:  nil,
            ssoType:    1,
            action:     'Continue'
          }
          response = Curl.post "#{@juniper_url}/dana/home/userpass.cgi", params
          puts response.header_str
          puts response.body_str
          puts '[Juniper] Sharepoint has been set up'
        end
      end

      def cancel_previous_authentications location
        doc      = Nokogiri::HTML open location
        element  = (doc.css '#DSIDFormDataStr').first
        key      = element.attribute 'value'
        response = Curl.post login_url, 'FormDataStr' => key, 'btnContinue' => 'Poursuivre la session'
        @dsid    = get_cookie_from_header response.header_str, 'DSID'
      end

      def authenticate_to_juniper user, password, domain
        response = Curl.post login_url, username: user, password: password, realm: 'Users'
        @dsid    = get_cookie_from_header response.header_str, 'DSID'

        if @dsid.nil? and (response.response_code == 302)
          location = get_redirect_location response.header_str
          cancel_previous_authentications location unless location.nil?
        end

        authentication_failed response.body_str if @dsid.nil?
        ensure_sharepoint_initialization user, password, domain
      end

      def get_cookie_from_header header, cookie_name
        result = nil
        header.scan(/#{cookie_name}=([^;]+);/) do
          offset = $~.offset 1
          result = header[offset[0]..offset[1] - 1]
        end
        result
      end

      def get_redirect_location header
        location   = nil
        header.scan(/location: (.*)/) do
          offset   = ($~.offset 1)
          location = header[offset[0]..offset[1] - 1]
        end
        location
      end

      def authentication_failed xml
        message   = 'Unknown authentication error'
        raise AuthenticationFailed.new message
      end
    end
  end
end

