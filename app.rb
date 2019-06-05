require "bundler/setup"
require "forwardable"
require "sinatra"
require "net/http"
require "pathname"

root_path = Pathname.new(__FILE__).join("..").expand_path

$:.unshift(root_path.join("lib"))

require "proxy"

Proxy::Configuration.configure do |config|
  config.base_url     = "https://tessituradev.sheddaquarium.hq/Dev/TessituraService"
  config.http_options = {verify_mode: OpenSSL::SSL::VERIFY_NONE}
end

[:get, :post, :put, :delete].each do |verb|
  send(verb, "*path") do
    response = Proxy.new(request).forward
    [response.code, response.headers, response.body]
  end
end
