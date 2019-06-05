class Proxy
  class Configuration
    class << self
      attr_accessor :base_url
      attr_writer :http_options

      def http_options
        @http_options || {}
      end

      def configure(&block)
        yield self
      end
    end
  end
end
