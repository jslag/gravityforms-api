require 'faraday'
require 'base64'
require 'cgi'
require 'openssl'

module Gravityforms
  module Api
    class Request
      attr_reader :url
      def initialize(route, method, per_page=20, offset=0, timeout=5)
        expires = (Time.now+60*60).to_i
        api_key = Gravityforms::Api.configuration.api_key
        api_url = Gravityforms::Api.configuration.api_url
        signature = calculate_signature(route, method, expires, api_key)
        encode = "?api_key=#{api_key}&expires=#{expires}&signature=#{signature}&paging[page_size]=#{per_page}&paging[offset]=offset"
        @url = "#{api_url}#{route}/#{encode}"

        @connection = Faraday::Connection.new(nil, request: { timeout: timeout })
      end

      def get
        response = @connection.get(self.url)
      end

      def post(payload)
        response = @connection.post(self.url, payload)
      end

      def calculate_signature(route, method, expires, api_key)
        private_key = Gravityforms::Api.configuration.private_key
        string_to_sign = sprintf("%s:%s:%s:%s", api_key, method, route, expires)
        hmac = OpenSSL::HMAC.digest('sha1',private_key,string_to_sign)
        signature = CGI.escape(Base64.encode64("#{hmac}")).gsub("%0A", "")
        #puts route + " : " + string_to_sign + " : " + signature
        return signature
      end
    end
  end
end
