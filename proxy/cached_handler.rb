require_relative 'http_request'
require_relative 'request_handler'
require_relative 'proxy_handler'
require_relative 'http_cache'
require 'yaml'
require 'time'

class CachedHandler
  include RequestHandler

  def initialize(em)
    @em = em
    @successor = ProxyHandler.new(em)
  end

  def handle_request(http_request)
    if can_process?(http_request)
      puts "Handled by cached handler."
      handle(http_request)
    else
      @successor.handle_request(http_request)
    end
  end

  private
    def can_process?(http_request)
      if http_request.http_method == 'POST'
        return false
      end

      if http_request.header['Cache-control'] == 'no-cache'
        return false
      end
      true
    end

    def handle(http_request)
      cache_key = http_request.uri
      raw_cache = HttpCache.try_restore_from_cache(cache_key)
      if raw_cache != nil
        cached_response = YAML::load(raw_cache)
        if is_expired?(cached_response)
          @successor.handle_request(http_request)
          return
        end
        send_response(@em, cached_response)
        puts 'Response retrieved from cache.'
      else
        @successor.handle_request(http_request)
      end
    end

    def is_expired?(http_request)
      expiration_time = http_request.header['Expires']
      if expiration_time != nil
        return Time.httpdate(expiration_time) < Time.now
      end
    end
end
