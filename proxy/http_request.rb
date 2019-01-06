class HttpRequest
  def initialize(method, uri, header, body)
    @method = method
    @uri = uri
    @header = header
    @body = body
  end

  def http_method
    @method
  end

  def uri
    @uri
  end

  def header
    @header
  end

  def body
    @body
  end
end
