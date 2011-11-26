require 'spec_helper'
require 'command_line_reporter'

describe CommandLineReporter do
  let :use_class do
    Class.new do
      include CommandLineReporter
    end
  end

  subject { use_class.new }

  describe '#formatter=' do
    it 'only allows allowed formatters' do
      lambda {
        subject.formatter = 'asfd'
      }.should raise_exception ArgumentError
    end

    it 'specifies the progress formatter' do
      subject.formatter = 'progress'
      subject.formatter.class.should == CommandLineReporter::ProgressFormatter
    end

    it 'specifies the nested formatter' do
      subject.formatter = 'nested'
      subject.formatter.class.should == CommandLineReporter::NestedFormatter
    end
  end

  describe '#report' do
    it 'uses the nested formatter as default' do
      subject.report do
        # nothing
      end
      subject.formatter.class.should == CommandLineReporter::NestedFormatter
    end
  end
end
