require "active_record"
require "set"

class Stacks::ColumnDependentCache

  extend Stacks::Cache

  class << self
    attr_accessor :default_ttl, :cache_filling_job
  end

  # Expire everything after one week
  self.default_ttl = 60*60*24*7

  class InvalidModel < Exception; end

  def self.validate_model(model)
    raise InvalidModel.new(model.to_s) unless model < ActiveRecord::Base
  end

  def self.get_backend(model)
    backend = Stacks::Backends::NamespacedBackend.new
    backend.namespace = model.to_s
    backend
  end

  def self.defined_blocks
    @defined_caches ||= {}
  end

  def self.fillable_block_keys
    @fillable_block_keys ||= Hash.new { |h, k| h[k] = {} }
  end

  def self.get_block_value(identifier)
    item = defined_blocks[identifier]
    backend = get_backend(item.model)

    get_value(item, backend, default_ttl)
  end

  def self.define_block(model, columns, identifier, &block)
    item = get_item(model, columns, identifier, block)
    defined_blocks[identifier] = item
    fillable_block_keys[model][item.key] = item
  end

  def self.make_fill_decision(model, key)
    if cache_filling_job
      cache_filling_job.call(model, key)
    else
      fill_block(model, key)
    end
  end

  def self.fill_block(model, key)
    item = fillable_block_keys[model][key]
    backend = get_backend(item.model)
    backend.fill(item, default_ttl)
  end

  def self.get_item(model, columns, identifier, block)
    validate_model(model)
    columns = [columns] unless columns.is_a?(Array)
    Stacks::Items::ColumnDependentBlock.new(model, columns, identifier, block)
  end

  def self.cached(model, columns, identifier, &block)
    backend = get_backend(model)
    item = get_item(model, columns, identifier, block)

    get_value(item, backend, default_ttl)
  end

  def self.bust_cache(model, columns)
    backend = get_backend(model)
    columns = columns.map { |c| c.to_s }

    fill_keys = Set.new
    del_keys = Set.new

    backend.keys.each do |key|
      potential_columns = Stacks::Items::ColumnDependentBlock.key_to_columns(key)

      columns.each do |column|
        if potential_columns.include?(column)
          if fillable_block_keys[model].keys.include?(key)
            fill_keys << [model, key]
            next
          end

          del_keys << key
        end
      end
    end

    fill_keys.each { |model, key| make_fill_decision(model, key) }
    del_keys.each { |key| backend.del_key(key) }
  end

end
