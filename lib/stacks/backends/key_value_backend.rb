require_relative 'backend'

class Stacks::Backends::KeyValueBackend

  include Stacks::Backends::Backend

  def backend_key
    "kv"
  end

  def get(item)
    potential_value = Stacks.redis.get(key(item))
    raise Stacks::NoValueException unless potential_value
    Marshal.load(potential_value) if potential_value
  end

  def set(item)
    value = item.value
    Stacks.redis.set(key(item), Marshal.dump(value))
    value
  end

  def del(item)
    Stacks.redis.del(key(item))
  end

  def expire(item, ttl)
    Stacks.redis.expire(key(item), ttl)
  end

end
