class Proxy
  class HeaderConverter
    def initialize(key)
      @key = key
    end

    def to_s
      @key.split(/[_-]/).map(&:capitalize).join("-")
    end
  end
end
