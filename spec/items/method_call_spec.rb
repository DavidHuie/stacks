require "spec_helper"
require 'digest/sha2'

describe Stacks::Items::MethodCall do

  before(:each) do
    @instance = TestClass.new
    @args = ["woo", "yoo"]
    @method_call = Stacks::Items::MethodCall.new(@instance, :test_method, @args)
  end

  describe "#key_str" do

    it "contains the method name" do
      @method_call.key_str.include?(:test_method.to_s).should be_true
    end

    it "contains the marshaled object" do
      @method_call.key_str.include?(Marshal.dump(@instance)).should be_true
    end

    it "contains the marshaled arguments" do
      @method_call.key_str.include?(Marshal.dump(@args)).should be_true
    end

  end

  describe "#key" do

    it "contains the SHA2 value of the key_str" do
      @method_call.key.should == Digest::SHA2.hexdigest(@method_call.key_str)
    end

  end

  describe "#value" do

    it "calls the method with the arguments" do
      @method_call.value.should == "My arguments: woo and yoo"
    end

  end

end
