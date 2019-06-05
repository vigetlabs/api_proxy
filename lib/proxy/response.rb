class Proxy
  class Response
    def initialize(http_response)
      @http_response = http_response
    end

    def code
      @http_response.code.to_i
    end

    def headers
      @http_response.each.inject({}) do |mapping, (key, value)|
        mapping.merge(HeaderConverter.new(key).to_s => value)
      end
    end

    def body
      @body ||= @http_response.body
    end
  end
end
