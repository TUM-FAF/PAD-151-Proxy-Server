require_relative 'http_request'

module RequestHandler
  def handle_request(http_request)
    raise NotImplementedError
  end
end