require_relative 'backend'

class Stacks::Backends::NamespacedBackend

  include Stacks::Backends::Backend

  attr_accessor :namespace

  def backend_key
    "n"
  end

  def prefix_keys
    super << @namespace
  end

  def get(item)
    potential_value = Stacks.redis.hget(prefix_key, suffix_key(item))
    raise Stacks::NoValueException unless potential_value
    return Marshal.load(potential_value) if potential_value
  end

  def set(item)
    value = item.value
    Stacks.redis.hset(prefix_key, suffix_key(item), Marshal.dump(value))
    value
  end

  def expire(item, ttl)
    Stacks.redis.expire(prefix_key, ttl)
  end

  def clear_cache
    Stacks.redis.del(prefix_key)
  end

  def keys
    Stacks.redis.hkeys(prefix_key)
  end

  def del_key(key)
    Stacks.redis.hdel(prefix_key, key)
  end

  def del(item)
    del_key(suffix_key(item))
  end

end
