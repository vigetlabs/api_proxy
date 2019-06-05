class Proxy
  class ForwardableHeader
    EXCLUDED = ["HTTP_VERSION","HTTP_HOST"].freeze
    INCLUDED = ["CONTENT_TYPE"].freeze

    attr_reader :value

    def initialize(raw_key, value)
      @raw_key = raw_key
      @value   = value
    end

    def forwardable?
      !excluded? && (included? || http_header?)
    end

    def key
      HeaderConverter.new(@raw_key.sub(/^HTTP_/, '')).to_s
    end

    def to_h
      {key => value}
    end

    private

    def excluded?
      EXCLUDED.include?(@raw_key)
    end

    def included?
      INCLUDED.include?(@raw_key)
    end

    def http_header?
      @raw_key.start_with?("HTTP_")
    end
  end
end
