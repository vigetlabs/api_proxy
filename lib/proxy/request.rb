class Proxy
  class Request
    def initialize(method_name, path, params: {}, headers: {}, body: nil)
      @method_name = method_name
      @path        = path
      @params      = params
      @headers     = headers
      @body        = body
    end

    def perform
      request = request_class.new(uri)

      @headers.each {|h| request[h.key] = h.value }

      http_response = Net::HTTP.start(uri.host, uri.port, options) do |http|
        http.request(request)
      end

      Response.new(http_response)
    end

    private

    def request_class
      Net::HTTP.const_get(@method_name.capitalize)
    end

    def default_options
      {use_ssl: uri.scheme == "https" }
    end

    def options
      default_options.merge(Proxy::Configuration.http_options)
    end

    def uri
      base_uri.tap {|u| u.path << @path }
    end

    def base_uri
      @base_uri ||= URI(Proxy::Configuration.base_url)
    end
  end
end