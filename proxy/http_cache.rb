require 'redis'

module HttpCache

  def init_cache
    @redis = Redis.new(host: 'redis', port: 6379)
  end

  def store_in_cache(key, value, expiry = 10)
    @redis.set(key, value)
    @redis.expire(key, expiry)
  end

  def try_restore_from_cache(key)
    @redis.get(key)
  end
end

