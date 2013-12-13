require 'spec_helper'

class TestBackend

  include Stacks::Backends::Backend

  def backend_key
    "test_backend_key"
  end

end

describe Stacks::Backends::Backend do

  before(:each) do
    @backend = TestBackend.new
    @item = double
  end

  describe ".prefix_keys" do

    it "includes the redis and backend prefix" do
      @backend.prefix_keys.should == ["stacks", "test_backend_key"]
    end

    context "set extra prefix" do

      before(:each) do
        Stacks.extra_prefix = lambda { "test_extra_prefix" }
      end

      after(:each) do
        Stacks.extra_prefix = nil
      end

      it "now includes 3 keys, including the extra prefix" do
        @backend.prefix_keys.should == ["stacks", "test_backend_key", "test_extra_prefix"]
      end

    end

  end

  describe "#prefix_key" do

    it "joins the prefix keys with the separator" do
      @backend.prefix_key.should == "stacks:test_backend_key"
    end

  end

  describe "#suffix_key" do

    it "returns the items key" do
      @item.should_receive(:key).and_return("test_key")
      @backend.suffix_key(@item).should == "test_key"
    end

  end

  describe "#fill" do

    it "should set and expire an item" do
      ttl = 100
      @backend.should_receive(:set).with(@item)
      @backend.should_receive(:expire).with(@item, ttl)

      @backend.fill(@item, ttl)
    end

  end

  describe "#get_or_set" do

    it "returns the item's value if it's a cache hit" do
      @backend.stub(:get).and_return("test_value")
      @backend.should_receive(:fill).exactly(0).times

      @backend.get_or_set(@item, 100).should == "test_value"
    end

    it "fills the cache with item's value if it's not a cache hit" do
      @backend.stub(:get).and_raise(Stacks::NoValueException)
      @backend.should_receive(:fill).exactly(1).times.with(@item, 100).and_return("test_value")

      @backend.get_or_set(@item, 100).should == "test_value"
    end

    it "does not call fill if an unmarshaled value is nil" do
      @backend.stub(:get).and_return(nil)
      @backend.should_receive(:fill).exactly(0).times

      @backend.get_or_set(@item, 100).should == nil
    end

  end

end
