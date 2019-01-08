require_relative 'http_request'
require_relative 'http_response'
require_relative 'http_cache'
require 'time'

class CachePolicy

  def initialize
    @default_expiry = 60
  end

  def allows_cached_response?(request)
    is_safe_method?(request) and allows_cache?(request)
  end

  def is_safe_method?(request)
    request.http_method == 'GET'
  end

  def allows_cache?(request)
    request.header['Cache-Control'] != 'no-cache'
  end

  def outdated_cache?(request, cached_response)
    delta_seconds = request.header['Cache-Control']&.split('=')[1].to_i \
      if request.header['Cache-Control']&.start_with?('max-age')

    last_modified = cached_response.header['Last-Modified']
    if delta_seconds != nil and last_modified != nil
      return Time.now - Time.httpdate(last_modified) > delta_seconds
    end
    false
  end

  def get_expiration_time(request)
    expiration_time = request.header['Expires']
    if expiration_time != nil
      return (Time.httpdate(expiration_time) - Time.now).to_i
    end
    @default_expiry
  end

  def should_update_cache?(key, response)
    raw_cache = HttpCache.try_restore_from_cache(key)
    if raw_cache != nil
      cached_response = YAML::load(raw_cache)
      cached_time = cached_response.header['Last-Modified']
      response_time = response.header['Last-Modified']
      if cached_time == nil or response_time == nil
        return true
      end
      return Time.httpdate(cached_time) < Time.httpdate(response_time)
    end
    true
  end
end
