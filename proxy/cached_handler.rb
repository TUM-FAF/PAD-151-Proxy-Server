require_relative 'http_request'
require_relative 'http_response'
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
      puts "Handled by #{self.class.to_s}."
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

      if http_request.header['Cache-Control'] == 'no-cache'
        return false
      end
      true
    end

    def handle(http_request)
      cache_key = http_request.uri
      raw_cache = HttpCache.try_restore_from_cache(cache_key)
      if raw_cache != nil
        cached_response = YAML::load(raw_cache)
        if is_too_old?(http_request, cached_response)
          puts "Passed to #{@successor.class.to_s}."
          @successor.handle_request(http_request)
          return
        end
        send_response(@em, cached_response)
        puts 'Response retrieved from cache.'
      else
        puts "Passed to #{@successor.class.to_s}."
        @successor.handle_request(http_request)
      end
    end

    def is_too_old?(http_request, cached_response)
      delta_seconds = http_request.header['Cache-Control']&.split('=')[1].to_i \
        if http_request.header['Cache-Control']&.start_with?('max-age')

      last_modified = cached_response.header['Last-Modified']
      if delta_seconds != nil and last_modified != nil
        return Time.now - Time.httpdate(last_modified) > delta_seconds
      end
      false
    end
end
