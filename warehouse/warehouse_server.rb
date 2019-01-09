require 'eventmachine'
require 'evma_httpserver'
require_relative 'connect_db'
require_relative 'http_request'
require_relative 'http_response'
require_relative 'request_handler'

class WarehouseServer < EM::Connection
  include EM::HttpServer

  def post_init
    super
    @db = ConnectDB.new('faf')
    no_environment_strings
    @handler = RequestHandler.new(self, @db)
  end

  def process_http_request
    @headers = @http_headers.split("\x00").map{ |e| e.split(': ', 2) }.to_h
    @request = HttpRequest.new(@http_request_method, @http_request_uri, @headers, @http_post_content)

    puts "Request info:"
    p @request

    @handler.handle(@request)
  end
end
