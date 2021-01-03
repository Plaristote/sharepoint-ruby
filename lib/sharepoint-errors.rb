module Sharepoint
  class Error < StandardError; end

  class RequestError < Error; end
  class DataError < Error
    def initialize data, uri = nil, body = nil
      @data = data['error']
      @uri  = uri
      @body = body
    end

    def lang         ; @data['message']['lang']  ; end
    def message      ; @data['message']['value'] ; end
    def code         ; @data['code'] ; end
    def uri          ; @uri ; end
    def request_body ; @body ; end
  end

  # @deprecated Use DataError instead
  SPException = DataError
  deprecate_constant :SPException

  class UnsupportedType < Error
    attr_accessor :type_name

    def initialize type_name
      @type_name = type_name
    end

    def message
      "unsupported type '#{@type_name}'"
    end
  end
end
