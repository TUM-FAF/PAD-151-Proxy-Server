require_relative 'http_request'

module RequestHandler
  def handle_request(http_request)
    raise NotImplementedError
  end

  def send_response(em, headers, body, status = 200)
    response = EM::DelegatedHttpResponse.new(em)
    response.status = status
    response.content_type headers['CONTENT_TYPE']
    response.content = body
    response.send_response
  end
end
