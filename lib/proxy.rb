require "proxy/configuration"
require "proxy/forwardable_header"
require "proxy/header_converter"
require "proxy/request"
require "proxy/response"

class Proxy
  extend Forwardable

  def_delegators :@rack_request, :path, :params

  def initialize(rack_request)
    @rack_request = rack_request
  end

  def forward
    request.perform
  end

  def signature
    [path, request.signature].join("/")
  end

  private

  def request
    @request ||= Request.new(method_name, path,
      headers: headers,
      params:  params,
      body:    body
    )
  end

  def body
    @body ||= @rack_request.body
  end

  def method_name
    @rack_request.request_method
  end

  def headers
    all_headers.select(&:forwardable?)
  end

  def all_headers
    @rack_request.env.map {|k,v| ForwardableHeader.new(k, v) }
  end
end
