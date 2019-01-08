require_relative 'http_request'
require_relative 'http_response'
require_relative 'request_handler'
require_relative 'proxy_handler'
require_relative 'http_cache'
require_relative 'cache_policy'
require 'yaml'
require 'time'

class CachedHandler
  include RequestHandler

  def initialize(em)
    @em = em
    @successor = ProxyHandler.new(em)
    @policy = CachePolicy.new
  end

  def handle_request(http_request)
    if @policy.allows_cached_response?(http_request)
      puts "Handled by #{self.class.to_s}."
      handle(http_request)
    else
      puts "Passed to #{@successor.class.to_s}."
      @successor.handle_request(http_request)
    end
  end

  private
    def handle(http_request)
      cache_key = http_request.uri
      raw_cache = HttpCache.try_restore_from_cache(cache_key)
      if raw_cache != nil
        cached_response = YAML::load(raw_cache)
        if @policy.outdated_cache?(http_request, cached_response)
          puts "Passed to #{@successor.class.to_s}."
          @successor.handle_request(http_request)
          return
        end
        puts 'Response retrieved from cache.'
        send_response(@em, cached_response)
      else
        puts "Passed to #{@successor.class.to_s}."
        @successor.handle_request(http_request)
      end
    end
end
