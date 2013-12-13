require 'simplecov'
SimpleCov.start 'rails'

$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))
$LOAD_PATH.unshift(File.dirname(__FILE__))

require 'rspec'
require 'pry'
require 'mock_redis'
require 'stacks'

Stacks.redis = MockRedis.new

RSpec.configure do |config|

  config.before(:each) do
    Stacks.bust_all_caches
  end

end

class TestClass

  class << self
    attr_accessor :prefix
  end

  def test_method(arg1, arg2)
    "My arguments: #{arg1} and #{arg2}"
  end

  def test_method2(arg1, arg2)
    "#{self.class.prefix}: #{arg1} and #{arg2}"
  end

  def test_method3
    "this is a test"
  end

end

TestClass.prefix = "My arguments"

ActiveRecord::Base.establish_connection adapter: "sqlite3", database: ":memory:"
ActiveRecord::Schema.define do
  create_table :test_models, :force => true do |t|
    t.string :test_column1
    t.string :test_column2
  end
end

class TestModel < ActiveRecord::Base; end
class FakeModel; end
class TestCache1; end
class TestCache2; end
