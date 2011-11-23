$: << File.join(File.dirname(__FILE__), '..', 'lib')
require 'command_line_reporter'

describe CommandLineReporter do
  let :use_class do
    Class.new do
      include CommandLineReporter
    end
  end

  subject { use_class.new }

  describe "#report" do
    context 'argument validation' do
      it 'raises exception when there is an invalid argument' do
        lambda {
          subject.report(:asdf => true)
        }.should raise_exception /ArgumentError/
      end

      it 'raises an exception when a block is not given' do
        lambda {
          subject.report(:message => 'test')
        }.should raise_exception /ArgumentError/
      end

      it 'accepts valid arguments' do
        subject.should_receive(:puts).with('test')
        subject.should_receive(:puts).with('complete')

        lambda {
          subject.report(:message => 'test') do
          end
        }.should_not raise_exception
      end
    end
  end

  describe 'default values' do
    its(:clr_complete_string) { should eq 'complete' }
    its(:clr_indent_size) { should eq 2 }
  end
end
