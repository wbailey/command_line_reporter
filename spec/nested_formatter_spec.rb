require 'spec_helper'
require 'nested_formatter'

describe CommandLineReporter::NestedFormatter do
  subject { CommandLineReporter::NestedFormatter.instance }

  describe '#method default values' do
    its(:message_string) { should == 'working' }
    its(:complete_string) { should == 'complete' }
    its(:indent_size) { should eq 2 }
  end

  describe '#format' do
    context 'argument validation' do
      before :all do
        @indent_size = subject.indent_size
      end

      # Restore the singleton to its original state to ensure clean tests
      after :each do
        subject.indent_size = @indent_size
      end

      it 'raises exception when there is an invalid argument' do
        lambda {
          subject.format({:asdf => true}, lambda { })
        }.should raise_exception ArgumentError
      end

      it 'raises an exception when a block is not given' do
        lambda {
          subject.format({:message => 'test'})
        }.should raise_exception
      end

      it 'accepts valid arguments' do
        Kernel.should_receive(:puts).with('test')
        Kernel.should_receive(:puts).with('complete')

        lambda {
          subject.format({:message => 'test'}, lambda { }) do
          end
        }.should_not raise_exception
      end
    end

    describe '#puts' do
      it 'delegates to Kernel.puts' do
        Kernel.should_receive(:puts).exactly(3).times

        subject.format({}, lambda {
          subject.puts("test")
        })
      end
    end

    context 'not nested' do
      before :all do
        @complete_string = subject.complete_string
        @indent_size = subject.indent_size
      end

      # Restore the singleton to its original state to ensure clean tests
      after :each do
        subject.complete_string = @complete_string
        subject.indent_size = @indent_size
      end

      it 'performs a wrapped report' do
        Kernel.should_receive(:puts).with('working')
        Kernel.should_receive(:puts).with('complete')

        subject.format({ }, lambda { })
      end

      it 'performs a wrapped report overriding the message' do
        Kernel.should_receive(:puts).with('test')
        Kernel.should_receive(:puts).with('complete')

        subject.format({:message => 'test'}, lambda { })
      end

      it 'performs an inline report' do
        Kernel.should_receive(:print).with('test...')
        Kernel.should_receive(:puts).with('complete')
        Kernel.should_receive(:print).with('test2...')
        Kernel.should_receive(:puts).with('complete')

        subject.format({:message => 'test', :type => 'inline'}, lambda { })
        subject.format({:message => 'test2', :type => 'inline'}, lambda { })
      end

      it 'overrides the default for all invocations of a wrapped report' do
        subject.complete_string = 'done'
        Kernel.should_receive(:puts).with('test')
        Kernel.should_receive(:puts).with('done')
        Kernel.should_receive(:puts).with('test2')
        Kernel.should_receive(:puts).with('done')

        subject.format({:message => 'test'}, lambda { })
        subject.format({:message => 'test2'}, lambda { })
      end

      it 'overrides the default complete string for a wrapped report' do
        Kernel.should_receive(:puts).with('test')
        Kernel.should_receive(:puts).with('done')
        Kernel.should_receive(:puts).with('test2')
        Kernel.should_receive(:puts).with('finally')

        subject.format({:message => 'test', :complete => 'done'}, lambda { })
        subject.format({:message => 'test2', :complete => 'finally'}, lambda { })
      end

      it 'overrides the default complete string for an inline report' do
        Kernel.should_receive(:print).with('test...')
        Kernel.should_receive(:puts).with('done')
        Kernel.should_receive(:print).with('test2...')
        Kernel.should_receive(:puts).with('finally')

        subject.format({:message => 'test', :type => 'inline', :complete => 'done'}, lambda { })
        subject.format({:message => 'test2', :type => 'inline', :complete => 'finally'}, lambda { })
      end

      it 'performs another wrapped report to ensure defaul behavior' do
        Kernel.should_receive(:puts).with('test')
        Kernel.should_receive(:puts).with('complete')
        Kernel.should_receive(:puts).with('test2')
        Kernel.should_receive(:puts).with('complete')

        subject.format({:message => 'test'}, lambda { })
        subject.format({:message => 'test2'}, lambda { })
      end
    end

    context 'nested commands' do
      before :all do
        @indent_size = subject.indent_size
      end

      # Restore the singleton to its original state to ensure clean tests
      after :each do
        subject.indent_size = @indent_size
      end

      it 'indents the nested wrapped messages' do
        Kernel.should_receive(:puts).with('test')
        Kernel.should_receive(:puts).with('  test2')
        Kernel.should_receive(:puts).with('  complete')
        Kernel.should_receive(:puts).with('complete')

        nested = lambda {
        }

        subject.format({:message => 'test'}, lambda {
          subject.format({:message => 'test2'}, lambda {})
        })
      end

      it 'indents the multiple nested wrapped messages' do
        Kernel.should_receive(:puts).with('test')
        Kernel.should_receive(:puts).with('  test2')
        Kernel.should_receive(:puts).with('    test3')
        Kernel.should_receive(:puts).with('    complete')
        Kernel.should_receive(:puts).with('  complete')
        Kernel.should_receive(:puts).with('complete')

        subject.format({:message => 'test'}, lambda {
          subject.format({:message => 'test2'}, lambda {
            subject.format({:message => 'test3'}, lambda { })
          })
        })
      end

      it 'indents the nested wrapped and inline messages' do
        Kernel.should_receive(:puts).with('test')
        Kernel.should_receive(:print).with('  test2...')
        Kernel.should_receive(:puts).with('complete')
        Kernel.should_receive(:puts).with('complete')

        subject.format({:message => 'test'}, lambda {
          subject.format({:message => 'test2', :type => 'inline'}, lambda { })
        })
      end

      it 'indents the multiple nested wrapped messages' do
        Kernel.should_receive(:puts).with('test')
        Kernel.should_receive(:puts).with('  test2')
        Kernel.should_receive(:print).with('    test3...')
        Kernel.should_receive(:puts).with('complete')
        Kernel.should_receive(:puts).with('  complete')
        Kernel.should_receive(:puts).with('complete')

        subject.format({:message => 'test'}, lambda {
          subject.format({:message => 'test2'}, lambda {
            subject.format({:message => 'test3', :type => 'inline'}, lambda { })
          })
        })
      end

      it 'overrides the indent spacing of all messages' do
        Kernel.should_receive(:puts).with('test')
        Kernel.should_receive(:puts).with('    test2')
        Kernel.should_receive(:print).with('        test3...')
        Kernel.should_receive(:puts).with('complete')
        Kernel.should_receive(:puts).with('    complete')
        Kernel.should_receive(:puts).with('complete')

        subject.indent_size = 4

        subject.format({:message => 'test'}, lambda {
          subject.format({:message => 'test2'}, lambda {
            subject.format({:message => 'test3', :type => 'inline'}, lambda { })
          })
        })
      end

      it 'overrides the indent spacing of specific message' do
        Kernel.should_receive(:puts).with('test')
        Kernel.should_receive(:puts).with('      test2')
        Kernel.should_receive(:print).with('      test3...')
        Kernel.should_receive(:puts).with('complete')
        Kernel.should_receive(:puts).with('      complete')
        Kernel.should_receive(:puts).with('complete')

        subject.indent_size = 4

        subject.format({:message => 'test'}, lambda {
          subject.format({:message => 'test2', :indent_size => 6}, lambda {
            subject.format({:message => 'test3', :type => 'inline', :indent_size => 3}, lambda { })
          })
        })
      end

      it 'performs the sums specified in the block' do
        x,y,z = 0,0,0

        Kernel.should_receive(:puts).with('sum x and 10')
        Kernel.should_receive(:puts).with('  y is the difference of 20 and x')
        Kernel.should_receive(:puts).with('    z = x + y')
        Kernel.should_receive(:puts).with('    complete')
        Kernel.should_receive(:puts).with('  complete')
        Kernel.should_receive(:puts).with('complete')

        subject.format({:message => 'sum x and 10'}, lambda {
          x = x + 10
          subject.format({:message => 'y is the difference of 20 and x'}, lambda {
            y = 20 - x
            subject.format({:message => 'z = x + y'}, lambda {
              z = x + y
            })
          })
        })

        x.should == 10
        y.should == 10
        z.should == 20
      end
    end
  end
end
