require_relative 'http_request'
require_relative 'request_handler'
require_relative 'http_response'
require_relative 'proxy_get_handler'
require_relative 'proxy_post_handler'
require 'em-http-request'
require 'yaml'

class ProxyHandler
  include RequestHandler

  def initialize(em)
    @em = em
    @handlers = {
      'GET' => ProxyGetHandler.new(@em),
      'POST' => ProxyPostHandler.new(@em),
    }
  end

  def handle_request(http_request)
    puts "Handled by #{self.class.to_s}."
    handle(http_request)
  end

  private
    def handle(http_request)
      http_request.header['Accept'] = 'text/json'

      handler = @handlers[http_request.http_method]
      http = handler.execute(http_request)

      http.errback do
        puts "ERROR: #{http.error}"
      end

      http.callback do
        handler.callback(http, http_request)
      end
    end
end
