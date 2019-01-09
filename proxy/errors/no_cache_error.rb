class NoCacheError <  StandardError
  def initialize(msg = "No cached resource found.")
    super
  end
end
