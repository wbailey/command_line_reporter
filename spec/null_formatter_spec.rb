require 'spec_helper'
require 'null_formatter'

describe CommandLineReporter::NullFormatter do
  subject { CommandLineReporter::NullFormatter.instance }

  describe 'accessors' do
    it 'allows setting indicator' do
      subject.indicator = '.'
      subject.indicator.should == '.'
    end

    it 'allows setting indent size' do
      subject.indent_size = 3
      subject.indent_size.should == 3
    end

    it 'allows setting complete string' do
      subject.complete_string = '.'
      subject.complete_string.should == '.'
    end

    it 'allows setting message string' do
      subject.message_string = '.'
      subject.message_string.should == '.'
    end
  end

  describe '#method default values' do
    its(:indicator) { should == '.' }
  end

  describe '#format' do
    it 'displays nothing for the indicator' do
      Kernel.should_receive(:print).never
      Kernel.should_receive(:puts).never

      subject.format({}, lambda {
        10.times {subject.progress}
      })
    end

    it 'runs any supplied block' do
      x = 0
      subject.format({}, lambda{x=4})
      x.should == 4
    end
  end

  describe '#progress' do
    it 'allows override of the indicator and still displays nothing' do
      Kernel.should_receive(:print).never
      Kernel.should_receive(:puts).never

      subject.format({}, lambda {
        10.times {subject.progress('+')}
      })
    end
  end

  describe '#puts' do
    it 'do nothing' do
      Kernel.should_receive(:print).never
      Kernel.should_receive(:puts).never

      subject.format({}, lambda {
        subject.puts("test")
      })
    end
  end
end
