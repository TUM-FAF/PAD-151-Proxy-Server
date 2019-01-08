class OutdatedCacheError < StandardError
  def initialize(msg = "The cache is outdated.")
    super
  end
end
