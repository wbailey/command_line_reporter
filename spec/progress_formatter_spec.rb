require 'spec_helper'
require 'progress_formatter'

describe CommandLineReporter::ProgressFormatter do
  subject { CommandLineReporter::ProgressFormatter.instance }

  describe '#method default values' do
    its(:indicator) { should == '.' }
  end

  describe '#format' do
    it 'displays dots for the indicator' do
      subject.should_receive(:print).exactly(10).times.with('.')
      subject.should_receive(:puts).exactly(1).times

      subject.format({}, lambda {
        10.times {subject.progress}
      })
    end

    it 'uses the defined indicator' do
      subject.indicator = '+'
      subject.should_receive(:print).exactly(10).times.with('+')
      subject.should_receive(:puts)

      subject.format({}, lambda {
        10.times {subject.progress}
      })

    end

    it 'allows override of the indicator' do
      subject.should_receive(:print).exactly(10).times.with('=')
      subject.should_receive(:puts)

      subject.format({:indicator => '='}, lambda {
        10.times {subject.progress}
      })
    end
  end

  describe '#progress' do
    it 'allows override of the indicator' do
      subject.should_receive(:print).exactly(10).times.with('+')
      subject.should_receive(:puts)

      subject.format({}, lambda {
        10.times {subject.progress('+')}
      })
    end

    it 'allows any indicator' do
      subject.should_receive(:print).exactly(10).times
      subject.should_receive(:puts)

      subject.format({}, lambda {
        10.times {|i| subject.progress("#{i}")}
      })
    end
  end
end
