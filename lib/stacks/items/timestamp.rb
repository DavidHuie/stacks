class Stacks::Items::Timestamp

  def key
    "cache_timestamp"
  end

  def value
    Time.now
  end

end
