class NotCacheableError < StandardError
  def initialize(msg = "The resource can't be cached.")
    super
  end
end
