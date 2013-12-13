require "spec_helper"

describe Stacks::Items::ColumnDependentBlock do

  before(:each) do
    @model = TestModel
    @columns = [:column1]
    @identifier = "identifier"
    @proc = lambda { "woo" }

    @cdb = Stacks::Items::ColumnDependentBlock.new(@model,
                                                    @columns,
                                                    @identifier,
                                                    @proc)
  end

  describe "#key" do

    it "consists of the identifier and the columns" do
      @cdb.key.should == "identifier:column1"
    end

  end

  describe ".key_to_columns" do

    it "drops the identifier from the key and returns the columns"do
      Stacks::Items::ColumnDependentBlock.key_to_columns("identifier:column1").should ==
        ["column1"]
    end

  end

  describe "#value" do

    it "just calls the proc" do
      @cdb.value.should == "woo"
    end

  end

end
