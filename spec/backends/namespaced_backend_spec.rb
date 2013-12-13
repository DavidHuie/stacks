require "spec_helper"

describe Stacks::Backends::NamespacedBackend do

  before(:each) do
    @backend = Stacks::Backends::NamespacedBackend.new
    @backend.namespace = "test_namespace"
    @item = double
  end

  describe "#prefix_keys" do

    it "includes the namespace in the prefix keys" do
      @backend.prefix_keys.include?("test_namespace")
    end

  end

  describe "#prefix_key" do

    it "includes the name space in the full key" do
      @backend.prefix_key.include?("test_namespace")
    end

  end

  context "with prefix and suffix keys" do

    before(:each) do
      @item.stub(:key) { "test_key" }
      @item.stub(:value) { "test_value" }
    end

    describe "#get" do

      it "returns the unmarshaled value of what's stored for the item" do
        Stacks.redis.hset(@backend.prefix_key,
                           @backend.suffix_key(@item),
                           Marshal.dump(@item.value))
        @backend.get(@item).should == "test_value"
      end

    end

    describe "#set" do

      it "stores the marshaled version of an item's value in the cache" do
        @backend.set(@item)
        @backend.get(@item).should == "test_value"
      end

    end

    describe "#expire" do

      it "sets a redis expiration for the prefix key" do
        Stacks.redis.should_receive(:expire).with(@backend.prefix_key, 666)
        @backend.expire(@item, 666)
      end

    end

    describe "#clear_cache" do

      it "deletes all keys under the namespace" do
        backend1 = Stacks::Backends::NamespacedBackend.new
        backend1.namespace = "test_namespace1"
        backend2 = Stacks::Backends::NamespacedBackend.new
        backend2.namespace = "test_namespace2"

        backend1.set(@item)
        backend2.set(@item)

        backend1.get(@item).should == @item.value
        backend2.get(@item).should == @item.value

        backend1.clear_cache

        expect { backend1.get(@item) }.to raise_error(Stacks::NoValueException)
        backend2.get(@item).should == @item.value
      end

    end

    describe "#keys" do

      it "returns the various suffix keys used in the namespace" do
        @backend.set(@item)
        @backend.keys.should == [@item.key]
      end

    end

    describe "#del" do

      it "removes the item from the cache" do
        expect { @backend.get(@item) }.to raise_error(Stacks::NoValueException)
        @backend.set(@item)
        @backend.get(@item).should == "test_value"
        @backend.del(@item)
        expect { @backend.get(@item) }.to raise_error(Stacks::NoValueException)
      end

    end

  end

end
