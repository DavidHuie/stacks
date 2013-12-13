require "spec_helper"

describe Stacks::ModelExtensions do

  describe ".bust_cache_for_column" do

    it "documents that a cache is watching a column" do
      Stacks.model_listening_caches.each do |cache|
        cache.should_receive(:bust_cache).with(TestModel, [:test_column])
      end

      Stacks::ModelExtensions.bust_cache_for_column(TestModel, :test_column)
    end

  end

end

describe Stacks::ModelExtensions::Extension do

  describe ".stacks_watched_columns" do

    it "is attached to every model" do
      ActiveRecord::Base.stacks_watched_columns.is_a?(Set).should be_true
    end

  end

  describe ".stacks_watch_columns" do

    after(:each) { TestModel.stacks_watched_columns.clear }

    it "adds a column to the watch set" do
      TestModel.stacks_watched_columns.should == Set.new

      TestModel.stacks_watch_column(:test_column1)
      TestModel.stacks_watch_column(:test_column2)

      TestModel.stacks_watched_columns.should == Set.new([:test_column1, :test_column2])
    end

  end

  describe ".bust_stackss" do

    after(:each) { TestModel.stacks_watched_columns.clear }

    it "busts caches for each watched attribute" do
      TestModel.stacks_watch_column(:test_column1)
      TestModel.stacks_watch_column(:test_column2)

      TestModel.stacks_watched_columns.count.should == 2

      Stacks::ModelExtensions.should_receive(:bust_cache_for_columns).with(TestModel,
                                                                            Set.new([:test_column1,
                                                                                     :test_column2]))

      TestModel.bust_stacks
    end

  end

  describe ".stacks_check_columns" do

    it "is included in all models now" do
      ActiveRecord::Base.instance_methods.include?(:stacks_check_columns).should be_true
    end

    context "modify column" do

      before(:each) do
        TestModel.stacks_watch_column(:test_column1)
      end

      after(:each) { TestModel.stacks_watched_columns.clear }

      it "busts the column cache when the attribute is modified" do
        Stacks.model_listening_caches.each do |cache|
          cache.should_receive(:bust_cache).exactly(1).times.with(TestModel, [:test_column1])
        end

        y = TestModel.create
        y.test_column1 = "hello!"
        y.save!
      end

      it "busts the column cache when the attribute is modified at creation time" do
        Stacks.model_listening_caches.each do |cache|
          cache.should_receive(:bust_cache).exactly(1).times.with(TestModel, [:test_column1])
        end

        y = TestModel.create(:test_column1 => "hello!")
      end

      it "doesn't trigger the callback for a non-watched column" do
        Stacks.model_listening_caches.each do |cache|
          cache.should_receive(:bust_cache).exactly(0).times
        end

        y = TestModel.create(:test_column2 => "hello!")
      end

    end

  end
end
