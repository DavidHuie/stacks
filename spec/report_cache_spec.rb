require "spec_helper"

describe Stacks::ReportCache do

  before(:each) do
    @report = Stacks::ReportCache.new("test report", 100)
  end

  describe "#backend" do

    it "uses a namespaced backend customized to the report name" do
      backend = @report.backend
      backend.namespace.should == "test report"
    end

  end

  describe ".report" do

    it "allows defining values through passing a block" do
      report = Stacks::ReportCache.report("test report", 100) do
        value("a test value") { "woooo" }
      end

      report.report_name.should == "test report"
      report.ttl.should == 100
      report.values["a test value"].key.should == "a test value"
      report.values["a test value"].value.should == "woooo"
    end

  end

  describe "#value" do

    it "defines a value for the report" do
      @report.value("hello there") { "wussup" }
      @report.values["hello there"].value.should == "wussup"
    end

  end

  describe "#get_value" do

    it "returns the cached value stored for the key" do
      @report.value("hello there") { "wussup" }
      @report.get_value("hello there").should == "wussup"
    end

    it "doesn't return a cached value if cache_condition evaluates to false" do
      @report.value("hello there") { "wussup" }
      @report.set_cache_condition { false }
      item = @report.values["hello there"]
      item.should_receive(:value)
      @report.backend.should_receive(:get_or_set).exactly(0).times

      @report.get_value("hello there")
    end

    it "returns a cached value if cache_condition evaluates to true" do
      @report.value("hello there") { "wussup" }
      @report.set_cache_condition { true }
      item = @report.values["hello there"]
      @report.backend.should_receive(:get_or_set)

      @report.get_value("hello there")
    end

  end

  describe "#fill_cache" do

    it "should fill the cache" do
      @report.value("hello there") { "wussup" }
      @report.value("yo") { "ratchet" }

      @report.values["hello there"].class.should == Stacks::Items::Proc
      @report.values["yo"].class.should == Stacks::Items::Proc

      @report.backend.should_receive(:fill).with(@report.values["hello there"], 100)
      @report.backend.should_receive(:fill).with(@report.values["yo"], 100)

      timestamp = double

      Stacks::Items::Timestamp.stub(:new).and_return(timestamp)
      @report.backend.should_receive(:fill).with(timestamp, 100)

      @report.fill_cache
    end

    it "shouldn't do anything if the cache condition isn't satisfied" do
      @report.value("yo") { "ratchet" }
      @report.values["yo"].class.should == Stacks::Items::Proc
      @report.set_cache_condition { false }
      @report.backend.should_receive(:fill).exactly(0).times

      @report.fill_cache
    end

  end

  describe ".reports" do

    it "keeps track of all defined reports" do
      report = Stacks::ReportCache.report("test report", 100) do
        value("a test value") { "woooo" }
      end

      Stacks::ReportCache.reports["test report"].should == report
      Stacks::ReportCache.get_report("test report").should == report
    end

  end

  describe "#register_instance_variables" do

    it "transfers create attributes for each value" do
      instance = TestClass.new
      report = Stacks::ReportCache.report("test report", 100) do
        value("my_attr") { "woooo" }
      end

      report.register_instance_variables(instance)
      instance.instance_eval { @my_attr }.should == "woooo"
    end

  end

  describe "#timestamp" do

    it "it returns a timestamp" do
      report = Stacks::ReportCache.report("test report", 100) do
        value("my_attr") { "woooo" }
      end

      report.timestamp.class.should == Time
    end

  end


end
