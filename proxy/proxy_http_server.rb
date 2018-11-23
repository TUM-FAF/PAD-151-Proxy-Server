require 'eventmachine'
require 'em-http-request'
require 'evma_httpserver'
require_relative 'http_cache'

class ProxyHttpServer < EM::Connection
  include EM::HttpServer
  include HttpCache

  def post_init
    super
    no_environment_strings
  end

  def process_http_request
    # the http request details are available via the following instance variables:
    #   @http_protocol
    #   @http_request_method
    #   @http_cookie
    #   @http_if_none_match
    #   @http_content_type
    #   @http_path_info
    #   @http_request_uri
    #   @http_query_string
    #   @http_post_content
    #   @http_headers

    http = EventMachine::HttpRequest.new('http://warehouse:9191').get
    http.errback { p 'Uh oh'}

    http.callback do
      p http.response_header.status
      p http.response_header
      p http.response
      content = http.response
      response = EM::DelegatedHttpResponse.new(self)
      response.status = 200
      response.content_type 'text/html'
      response.content = "<center>#{content}</center>"
      response.send_response
    end
  end
end
