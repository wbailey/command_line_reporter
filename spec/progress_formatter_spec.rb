require 'spec_helper'
require 'progress_formatter'

describe CommandLineReporter::ProgressFormatter do
  subject { CommandLineReporter::ProgressFormatter.instance }

  describe '#method default values' do
    its(:indicator) { should == '.' }
  end

  describe '#format' do
    it 'displays dots for the indicator' do
      Kernel.should_receive(:print).exactly(10).times.with('.')
      Kernel.should_receive(:puts).exactly(1).times

      subject.format({}, lambda {
        10.times {subject.progress}
      })
    end

    it 'uses the defined indicator' do
      subject.indicator = '+'
      Kernel.should_receive(:print).exactly(10).times.with('+')
      Kernel.should_receive(:puts)

      subject.format({}, lambda {
        10.times {subject.progress}
      })

    end

    it 'allows override of the indicator' do
      Kernel.should_receive(:print).exactly(10).times.with('=')
      Kernel.should_receive(:puts)

      subject.format({:indicator => '='}, lambda {
        10.times {subject.progress}
      })
    end
  end

  describe '#progress' do
    it 'allows override of the indicator' do
      Kernel.should_receive(:print).exactly(10).times.with('+')
      Kernel.should_receive(:puts)

      subject.format({}, lambda {
        10.times {subject.progress('+')}
      })
    end

    it 'allows any indicator' do
      Kernel.should_receive(:print).exactly(10).times
      Kernel.should_receive(:puts)

      subject.format({}, lambda {
        10.times {|i| subject.progress("#{i}")}
      })
    end
  end

  describe '#puts' do
    it 'delegates to Kernel.puts' do
      Kernel.should_receive(:puts).exactly(2).times

      subject.format({}, lambda {
        subject.puts("test")
      })
    end
  end
end
