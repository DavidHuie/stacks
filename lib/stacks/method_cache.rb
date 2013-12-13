module Stacks::MethodCache

  extend Stacks::Cache

  def self.backend
    Stacks::Backends::KeyValueBackend.new
  end

  def self.get_item(object, method, args, ttl)
    Stacks::Items::MethodCall.new(object, method, args)
  end

  def self.cached(object, method, args, ttl)
    item = get_item(object, method, args, ttl)
    get_value(item, backend, ttl)
  end

end
