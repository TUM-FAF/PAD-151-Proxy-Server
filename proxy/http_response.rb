class HttpResponse
  def initialize(status, header, body)
    @status = status
    @header = header
    @body = body
  end

  def status
    @status
  end

  def header
    @header
  end

  def body
    @body
  end

  def has_body?
    @body.length > 0
  end
end
