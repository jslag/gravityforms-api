require 'faraday'
require 'base64'
require 'cgi'
require 'openssl'

module Gravityforms
  module Api
    class Request
      attr_reader :url
      def initialize(route, method, per_page = 20, offset = 0, timeout = 5)
        expires = (Time.now + 60 * 60).to_i
        api_key = Gravityforms::Api.configuration.api_key
        api_url = Gravityforms::Api.configuration.api_url
        proxy = Gravityforms::Api.configuration.proxy

        signature = calculate_signature(route, method, expires, api_key)
        encode = "?api_key=#{api_key}&expires=#{expires}&signature=#{signature}&paging[page_size]=#{per_page}&paging[offset]=#{offset}"
        @url = "#{api_url}#{route}/#{encode}"

        request_params = {timeout:}
        request_params[:proxy] = proxy if proxy

        @connection = Faraday::Connection.new(nil, request: request_params)
      end

      def get
        @connection.get(url)
      end

      def post(payload)
        @connection.post(url, payload)
      end

      def calculate_signature(route, method, expires, api_key)
        private_key = Gravityforms::Api.configuration.private_key
        string_to_sign = sprintf("%s:%s:%s:%s", api_key, method, route, expires)
        hmac = OpenSSL::HMAC.digest("sha1", private_key, string_to_sign)
        CGI.escape(Base64.encode64(hmac.to_s)).gsub("%0A", "")
      end
    end
  end
end
