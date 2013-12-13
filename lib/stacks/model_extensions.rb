require "active_record"
require "set"

class Stacks::ModelExtensions

  def self.watched_models
    @watched_models ||= Set.new
  end

  def self.bust_cache_for_column(model, column)
    bust_cache_for_columns(model, [column])
  end

  def self.bust_cache_for_columns(model, columns)
    Stacks.model_listening_caches.each do |cache|
      cache.bust_cache(model, columns)
    end
  end

  module Extension

    def self.included(base)
      base.extend(ClassMethods)
      base.class_eval { before_save(:stacks_check_columns) }
    end

    def stacks_check_columns
      return unless Stacks::ModelExtensions.watched_models.include?(self.class)

      changed.each do |column|
        column = column.to_sym

        if self.class.stacks_watched_columns.include?(column)
          Stacks::ModelExtensions.bust_cache_for_column(self.class, column)
        end
      end
    end

    module ClassMethods

      def stacks_watched_columns
        @nbc_watched_columns ||= Set.new
      end

      def stacks_watch_column(column)
        stacks_watched_columns << column
        Stacks::ModelExtensions.watched_models << self
      end

      def bust_stacks
        Stacks::ModelExtensions.bust_cache_for_columns(self, stacks_watched_columns)
      end

    end

  end

end

ActiveRecord::Base.class_eval { include Stacks::ModelExtensions::Extension }
