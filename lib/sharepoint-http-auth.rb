require 'curb'
require 'cgi'

module Sharepoint
  module HttpAuth
    class Session
      attr_accessor :site
      attr_reader :user, :password

      def initialize site
        @site     = site
      end

      def authenticate user, password
        @user     = user
        @password = password
      end

      def cookie
        String.new
      end

      def curl curb
        curb.http_auth_types = :ntlm
        curb.username        = @user
        curb.password        = @password
      end
    end
  end
end
