require "forwardable"
require "pathname"
require "net/http"

require "bundler/setup"

require "sinatra"
require "vcr"
require "active_support/core_ext/object/to_query"

root_path = Pathname.new(__FILE__).join("..").expand_path

$:.unshift(root_path)
$:.unshift(root_path.join("lib"))

require "proxy"
require "configuration"

[:get, :post, :put, :delete].each do |verb|
  send(verb, "*path") do
    proxy = Proxy.new(request)

    VCR.use_cassette(proxy.signature) do
      response = proxy.forward
      [response.code, response.headers, response.body]
    end
  end
end
