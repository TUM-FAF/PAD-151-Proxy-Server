require 'eventmachine'
require 'em-http-request'
require 'evma_httpserver'
require_relative 'cached_handler'
require_relative 'http_request'

class ProxyHttpServer < EM::Connection
  include EM::HttpServer

  def post_init
    super
    HttpCache.init_cache
    @request_handler = CachedHandler.new(self)
    no_environment_strings
  end

  def process_http_request
    @headers = @http_headers.split("\x00").map{ |e| e.split(': ', 2) }.to_h
    @request = HttpRequest.new(@http_request_method, @http_request_uri, @headers, @http_post_content)

    puts "Request info:"
    p @request

    @request_handler.handle_request(@request)
  end
end
