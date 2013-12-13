require 'spec_helper'

describe Stacks::ColumnDependentCache do

  describe ".validate_model" do

    it "throws an exception if the model isn't an activerecord model" do
      expect do
        Stacks::ColumnDependentCache.validate_model(FakeModel)
      end.to raise_error(Stacks::ColumnDependentCache::InvalidModel)
    end

    it "doesn't throw an exception if the class is valid" do
      expect do
        Stacks::ColumnDependentCache.validate_model(TestModel)
      end.to_not raise_error
    end

  end

  describe ".get_backend" do

    it "returns a backend namespaced to the model" do
      backend = Stacks::ColumnDependentCache.get_backend(TestModel)
      backend.namespace.should == TestModel.to_s
    end

  end

  describe ".cached" do

    before(:each) do
      @model = TestModel
      @columns = [:col1, :col2, :col3]
      @identifier = "identifier"
    end

    let(:call) do
      Stacks::ColumnDependentCache.cached(@model,
                                           @columns,
                                           @identifier) { "wussup?" }
    end

    it "validates the model" do
      Stacks::ColumnDependentCache.should_receive(:validate_model).with(@model)
      call
    end

    context "test actual cacheing" do

      before(:each) do
        @model = TestClass
        @model.stub_chain(:nbc_listener, :register_column)
        Stacks::ColumnDependentCache.stub(:validate_model)
        @backend = double
      end


      it "uses a backend appropriate to the model" do
        @backend.stub(:get_or_set)

        Stacks::ColumnDependentCache.should_receive(:get_backend).with(@model).and_return(@backend)

        call
      end

      it "calls get_or_set on the backend" do
        item = double
        Stacks::Items::ColumnDependentBlock.stub(:new) { item }
        Stacks::ColumnDependentCache.stub(:get_backend) { @backend }

        @backend.should_receive(:get_or_set).with(item,
                                                  Stacks::ColumnDependentCache.default_ttl)

        call
      end

    end

  end

  describe ".bust_cache" do

    it "runs" do
      backend = Stacks::Backends::NamespacedBackend.new
      backend.namespace = "namespace"
      Stacks::ColumnDependentCache.stub(:get_backend) { backend }
      Stacks::ColumnDependentCache.bust_cache(TestModel, [:key1])
    end

    context "stubbed backend" do

      before(:each) do
        @backend = double
        @item = double
        @item.stub(:clear_value)
        @backend.stub(:keys) { ["identifier:key1", "identifier:key2"] }
        Stacks::ColumnDependentCache.stub(:get_backend) { @backend }
      end

      it "doesn't delete a key when it's a fillable block key" do
        Stacks::ColumnDependentCache.stub(:fillable_block_keys).and_return do
          { TestModel => { "identifier:key2" => @item } }
        end

        Stacks::ColumnDependentCache.should_receive(:make_fill_decision)
          .with(TestModel, "identifier:key2")
        @backend.should_receive(:del_key).exactly(0).times
        Stacks::ColumnDependentCache.bust_cache(TestModel, [:key2])
      end

      it "should delete each the key with given attribute" do
        @backend.should_receive(:del_key).exactly(1).times.with("identifier:key1")
        Stacks::ColumnDependentCache.bust_cache(TestModel, [:key1])
      end

      it "should delete a key with multiple columns, with one that matches" do
        @backend.stub(:keys) { ["identifier:key3:key7:key1", "identifier:key2"] }
        @backend.should_receive(:del_key).exactly(1).times.with("identifier:key3:key7:key1")
        Stacks::ColumnDependentCache.bust_cache(TestModel, [:key1])
      end

    end

  end

  describe ".fill_block" do

    it "should set the value when called with the correct key" do
      Stacks::ColumnDependentCache.define_block(TestModel, [:test_column1], "test_identifier") do
        "test_value"
      end

      Stacks::ColumnDependentCache.fillable_block_keys.keys.first.should == TestModel
      Stacks::ColumnDependentCache.defined_blocks.keys.should == ["test_identifier"]

      Stacks::ColumnDependentCache.fill_block(TestModel,
                                               "test_identifier:test_column1")

      Stacks::Backends::NamespacedBackend.any_instance.should_not_receive(:set)

      Stacks::ColumnDependentCache.get_block_value("test_identifier").should ==
        "test_value"
    end

  end

end
