module Stacks::Cache

  def get_value(item, backend, ttl)
    return item.value if Stacks.deactivate

    if Stacks.restrict
      return item.value unless Stacks.restrict.call
    end

    backend.get_or_set(item, ttl)
  end

end
