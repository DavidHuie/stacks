class Stacks

  class << self
    attr_accessor(:extra_prefix,
                  :redis,
                  :redis_prefix,
                  :key_separator,
                  :model_listening_caches,
                  :deactivate,
                  :restrict)
  end

  self.redis_prefix = "stacks"
  self.key_separator = ":"

  module Backends; end
  module Items; end

  class NoValueException < Exception; end

  def self.bust_all_caches
    keys = redis.keys("#{redis_prefix}*")

    redis.pipelined do
      keys.each { |key| redis.del(key) }
    end
  end

end

require 'stacks/backends/backend'
require 'stacks/backends/key_value_backend'
require 'stacks/backends/namespaced_backend'
require 'stacks/items/column_dependent_block'
require 'stacks/items/method_call'
require 'stacks/items/proc'
require 'stacks/items/timestamp'
require 'stacks/cache'
require 'stacks/method_cache'
require 'stacks/column_dependent_cache'
require 'stacks/report_cache'
require 'stacks/model_extensions'

Stacks.model_listening_caches = [Stacks::ColumnDependentCache]
