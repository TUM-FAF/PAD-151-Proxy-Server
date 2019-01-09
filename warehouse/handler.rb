require_relative 'http_request'
require_relative 'http_response'

module Handler
  def handle_request(http_request)
    raise NotImplementedError
  end

  def send_response(em, http_response)
    response = EM::DelegatedHttpResponse.new(em)
    response.status = http_response.status
    response.content_type http_response.header['Content-Type']
    response.content = http_response.body
    response.send_response
  end
end
