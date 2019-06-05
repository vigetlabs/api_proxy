require "proxy/configuration"
require "proxy/forwardable_header"
require "proxy/header_converter"
require "proxy/request"
require "proxy/response"

class Proxy
  extend Forwardable

  def_delegators :@request, :path, :params

  def initialize(request)
    @request = request
  end

  def forward
    request = Request.new(method_name, path, headers: headers, params: params, body: body)
    request.perform
  end

  private

  def body
    @body ||= @request.body
  end

  def method_name
    @request.request_method
  end

  def headers
    all_headers.select(&:forwardable?)
  end

  def all_headers
    @request.env.map {|k,v| ForwardableHeader.new(k, v) }
  end
end
