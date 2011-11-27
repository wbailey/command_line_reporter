require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe "handling results" do
  before do
    @autotest = Autotest.new
    @autotest.hook(:updated)
  end

  describe "for RSpec" do
    it "should show a 'passed' notification" do
      Autotest::Growl.should_receive(:growl).and_return('passed')
      @autotest.results = ["10 examples, 0 failures"]
      @autotest.hook(:ran_command)
    end
    it "should show a 'failed' notification" do
      Autotest::Growl.should_receive(:growl).and_return('failed')
      @autotest.results = ["10 examples, 1 failures"]
      @autotest.hook(:ran_command)
    end

    it "should show a 'pending' notification" do
      Autotest::Growl.should_receive(:growl).and_return('pending')
      @autotest.results = ["10 examples, 0 failures, 1 pending"]
      @autotest.hook(:ran_command)
    end

    it "should show an 'error' notification" do
      Autotest::Growl.should_receive(:growl).and_return('error')
      @autotest.results = []
      @autotest.hook(:ran_command)
    end
  end

  describe "for Test::Unit" do
    it "should show a 'passed' notification" do
      Autotest::Growl.should_receive(:growl).and_return('passed')
      @autotest.results = ["1 tests, 1 assertions, 0 failures, 0 errors"]
      @autotest.hook(:ran_command)
    end

    it "should show a 'failed' notification" do
      Autotest::Growl.should_receive(:growl).and_return('failed')
      @autotest.results = ["1 tests, 1 assertions, 1 failures, 0 errors"]
      @autotest.hook(:ran_command)
    end

    it "should show an 'error' notification" do
      Autotest::Growl.should_receive(:growl).and_return('error')
      @autotest.results = ["1 tests, 1 assertions, 0 failures, 1 errors"]
      @autotest.hook(:ran_command)
    end
  end

  describe "for Cucumber" do
    it "should show a 'passed' notification" do
      Autotest::Growl.should_receive(:growl).and_return('passed')
      @autotest.results = ["1 scenario (1 passed)", "1 step (1 passed)"]
      @autotest.hook(:ran_features)
    end

    it "should show a 'failed' notification" do
      Autotest::Growl.should_receive(:growl).and_return('failed')
      @autotest.results = ["2 scenarios (1 failed, 1 passed)", "2 steps (1 failed, 1 passed)"]
      @autotest.hook(:ran_features)
    end

    it "should show a 'pending' notification" do
      Autotest::Growl.should_receive(:growl).and_return('pending')
      @autotest.results = ["2 scenarios (1 undefined, 1 passed)", "2 steps (1 undefined, 1 passed)"]
      @autotest.hook(:ran_features)
    end

    it "should show an 'error' notification" do
      Autotest::Growl.should_receive(:growl).and_return('error')
      @autotest.results = []
      @autotest.hook(:ran_features)
    end
  end
end
