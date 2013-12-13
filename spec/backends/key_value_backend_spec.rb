require 'spec_helper'

describe Stacks::Backends::KeyValueBackend do

  before(:each) do
    @backend = Stacks::Backends::KeyValueBackend.new
    @key = "stacks:test_redis_key"
    @item = double
  end

  describe "#backend_key" do

    it "is set" do
      @backend.backend_key.should == "kv"
    end

  end

  describe "#hit?" do

    before(:each) do
      @backend.should_receive(:key).with(@item).and_return(@key)
    end

    it "returns true if the redis key is set" do
      Stacks.redis.set(@key, Marshal.dump("test_value"))
      @backend.get(@item).should == "test_value"
    end

    it "raises an exception if the redis key is not set" do
      expect { @backend.get(@item).should be_nil }.to raise_error(Stacks::NoValueException)
    end

  end

  describe "#get" do

    it "unmarshals what's stored at the key in redis" do
      Stacks.redis.set(@key, Marshal.dump("test_value"))
      @backend.should_receive(:key).with(@item).and_return(@key)
      @backend.get(@item).should == "test_value"
    end

  end

  describe "#set" do

    it "stores the item's value in redis" do
      @item.stub(:value) { "test_value" }
      @backend.should_receive(:key).with(@item).exactly(2).times.and_return(@key)
      @backend.set(@item)

      @backend.get(@item).should == "test_value"
    end

  end

  describe "#del" do

    it "deletes an item from redis" do
      @item.stub(:value) { "test_value" }
      @backend.should_receive(:key).with(@item).exactly(4).times.and_return(@key)
      @backend.set(@item)

      @backend.get(@item).should == "test_value"
      @backend.del(@item)

      expect { @backend.get(@item) }.to raise_error(Stacks::NoValueException)
    end

  end

  describe "#expire" do

    it "sets a redis expire for an item" do
      @backend.should_receive(:key).with(@item).and_return(@key)
      Stacks.redis.should_receive(:expire).with(@key, 100)
      @backend.expire(@item, 100)
    end

  end

end
