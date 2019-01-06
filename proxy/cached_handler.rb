require_relative 'http_request'
require_relative 'request_handler'
require_relative 'proxy_handler'
require_relative 'http_cache'

class CachedHandler
  include RequestHandler
  include HttpCache

  def initialize(em)
    @em = em
    init_cache
    @successor = ProxyHandler.new(em)
  end

  def handle_request(http_request)
    if can_process?(http_request)
      puts "Handled by cached handler."
      handle(http_request)
    else
      @successor.handle_request
    end
  end

  private
    def can_process?(http_request)
      if http_request.http_method == 'POST'
        return false
      end

      true
    end

    def handle(http_request)
      cache_key = [http_request.http_method, http_request.uri].join(' ')
      cache = try_restore_from_cache(cache_key)
      if cache != nil
        send_response(@em, {'CONTENT_TYPE' => 'application/xml'}, cache)
      else
        @successor.handle_request(http_request)
      end
    end
end
