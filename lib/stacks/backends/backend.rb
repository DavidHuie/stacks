module Stacks::Backends::Backend

  def prefix_keys
    keys = [Stacks.redis_prefix, backend_key]
    keys << Stacks.extra_prefix.call if Stacks.extra_prefix
    keys
  end

  def prefix_key
    prefix_keys.join(Stacks::key_separator)
  end

  def suffix_key(item)
    item.key
  end

  def key(item)
    [prefix_key, suffix_key(item)].join(Stacks::key_separator)
  end

  def fill(item, ttl)
    value = set(item)
    expire(item, ttl)
    value
  end

  def get_or_set(item, ttl)
    begin
      value = get(item)
      return value
    rescue Stacks::NoValueException

    end

    fill(item, ttl)
  end

end
