require "spec_helper"

describe Stacks::Items::Proc do

  describe "#initialize" do

    it "keeps track of a proc" do
      test_proc = proc { "hello" }
      item = Stacks::Items::Proc.new("test-identifier", test_proc)

      item.key.should == "test-identifier"
      item.value.should == "hello"
    end

  end

end
