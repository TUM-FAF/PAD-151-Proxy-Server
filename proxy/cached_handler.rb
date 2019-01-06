require_relative 'http_request'
require_relative 'request_handler'
require_relative 'proxy_handler'

class CachedHandler
  include RequestHandler
  
  def initialize
    @successor = ProxyHandler.new
  end

  def handle_request(http_request)
    if can_process?(http_request)
      puts "Handled by cached handler."
      handle(http_request)
    else
      @successor.handle_request
    end
  end

  def can_process?(http_request)
    false
  end

  private

    def handle(http_request)
      
    end
end