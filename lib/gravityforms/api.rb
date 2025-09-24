require "gem_config"
require "gravityforms/api/version"
require "gravityforms/api/request"
require "gravityforms/api/form"
require "dotenv"

Dotenv.load

module Gravityforms
  module Api
    include GemConfig::Base

    with_configuration do
      has :api_url, classes: String, default: (ENV['API_URL'] || "api_url")
      has :api_key, classes: String, default: (ENV['API_KEY'] || "api_key")
      has :private_key, classes: String, default: (ENV['PRIVATE_KEY'] || "private_key")
      has :proxy, classes: String, default: (ENV['PROXY'] || nil)
    end
  end
end
