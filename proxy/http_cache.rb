require 'redis'

class HttpCache

  def self.init_cache
    @redis = Redis.new(host: 'redis', port: 6379)
  end

  def self.store_in_cache(key, value, expiry = 10)
    @redis.set(key, value)
    @redis.expire(key, expiry)
  end

  def self.try_restore_from_cache(key)
    @redis.get(key)
  end

  def self.remove_from_cache(key)
    @redis.del(key)
  end
end
