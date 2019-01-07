require 'json'

class HttpResponse
  attr_accessor :status, :header, :body

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

  def self.json_create(o)
    new(*o)
  end

  def to_json(*a)
    { status: @status, header: @header, body: @body }.to_json(*a)
  end
end
