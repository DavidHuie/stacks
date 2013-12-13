require_relative 'spec_helper'

describe Stacks::MethodCache do

  before(:each) do
    @instance = TestClass.new
  end

  describe ".cached" do

    before(:each) do
      Stacks::MethodCache.cached(@instance,
                                  :test_method2,
                                  ["woo", "yoo"],
                                  666).should == "My arguments: woo and yoo"
    end

    it "should return the method value" do
      Stacks::MethodCache.cached(@instance,
                                  :test_method2,
                                  ["woo", "yoo"],
                                  666).should == "My arguments: woo and yoo"
    end

    it "should return the same value even if the method result" do
      TestClass.prefix = "HAHA"
      @instance.test_method2("woo", "yoo").should == "HAHA: woo and yoo"

      Stacks::MethodCache.cached(@instance,
                                  :test_method2,
                                  ["woo", "yoo"],
                                  666).should == "My arguments: woo and yoo"
      TestClass.prefix = "My arguments"
    end

    it "shouldn't conflict with other cached methods" do
      Stacks::MethodCache.cached(@instance,
                                  :test_method3,
                                  [],
                                  666).should == "this is a test"
    end

  end

end
