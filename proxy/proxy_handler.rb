require_relative 'http_request'
require_relative 'request_handler'

class ProxyHandler
  include RequestHandler

  def initialize

  end

  def handle_request(http_request)
    puts "Handled by proxy handler."
    handle(http_request)
  end

  private
    def handle(http_request)
      true
    end
  
end