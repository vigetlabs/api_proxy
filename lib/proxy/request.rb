class Proxy
  class Params
    extend Forwardable

    def_delegators :@params, :to_query, :any?

    def initialize(params)
      @params = params
    end

    def signature
      Digest::MD5.hexdigest(@params.sort.join)
    end
  end

  class Body
    def initialize(body)
      @body = body
    end

    def signature
      Digest::MD5.hexdigest(to_s)
    end

    def to_s
      @to_s ||= @body.read
    end
  end

  class Request
    def initialize(method_name, path, params: {}, headers: {}, body: nil)
      @method_name = method_name
      @path        = path
      @params      = Params.new(params)
      @headers     = headers
      @body        = Body.new(body)
    end

    def perform
      http_request = request_class.new(uri).tap do |request|
        request.body = @body.to_s
        @headers.each {|h| request[h.key] = h.value }
      end

      http_response = Net::HTTP.start(uri.host, uri.port, options) do |http|
        http.request(http_request)
      end

      Response.new(http_response)
    end

    def signature
      [@method_name, @params.signature, @body.signature].join("/")
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
      base_uri.tap do |uri|
        uri.path << @path
        uri.query = @params.to_query if @params.any?
      end
    end

    def base_uri
      @base_uri ||= URI(Proxy::Configuration.base_url)
    end
  end
end
