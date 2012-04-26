require 'spec_helper'
require 'nested_formatter'

describe CommandLineReporter::NestedFormatter do
  subject { CommandLineReporter::NestedFormatter.instance }

  let(:controls) do
    {
      :clear => "\e[0m",
      :bold => "\e[1m",
      :red => "\e[31m",
    }
  end

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
        subject.should_receive(:puts).with('test')
        subject.should_receive(:puts).with('complete')

        lambda {
          subject.format({:message => 'test'}, lambda { }) do
          end
        }.should_not raise_exception
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
        subject.should_receive(:puts).with('working')
        subject.should_receive(:puts).with('complete')

        subject.format({ }, lambda { })
      end

      it 'performs a wrapped report with color' do
        subject.should_receive(:puts).with("#{controls[:red]}working#{controls[:clear]}")
        subject.should_receive(:puts).with("#{controls[:red]}complete#{controls[:clear]}")

        subject.format({:color => 'red'}, lambda { })
      end

      it 'performs a wrapped report with color' do
        subject.should_receive(:puts).with("#{controls[:bold]}working#{controls[:clear]}")
        subject.should_receive(:puts).with("#{controls[:bold]}complete#{controls[:clear]}")

        subject.format({:bold => true}, lambda { })
      end

      it 'performs a wrapped report overriding the message' do
        subject.should_receive(:puts).with('test')
        subject.should_receive(:puts).with('complete')

        subject.format({:message => 'test'}, lambda { })
      end

      it 'performs an inline report' do
        subject.should_receive(:print).with('test...')
        subject.should_receive(:puts).with('complete')
        subject.should_receive(:print).with('test2...')
        subject.should_receive(:puts).with('complete')

        subject.format({:message => 'test', :type => 'inline'}, lambda { })
        subject.format({:message => 'test2', :type => 'inline'}, lambda { })
      end

      it 'overrides the default for all invocations of a wrapped report' do
        subject.complete_string = 'done'
        subject.should_receive(:puts).with('test')
        subject.should_receive(:puts).with('done')
        subject.should_receive(:puts).with('test2')
        subject.should_receive(:puts).with('done')

        subject.format({:message => 'test'}, lambda { })
        subject.format({:message => 'test2'}, lambda { })
      end

      it 'overrides the default complete string for a wrapped report' do
        subject.should_receive(:puts).with('test')
        subject.should_receive(:puts).with('done')
        subject.should_receive(:puts).with('test2')
        subject.should_receive(:puts).with('finally')

        subject.format({:message => 'test', :complete => 'done'}, lambda { })
        subject.format({:message => 'test2', :complete => 'finally'}, lambda { })
      end

      it 'overrides the default complete string for an inline report' do
        subject.should_receive(:print).with('test...')
        subject.should_receive(:puts).with('done')
        subject.should_receive(:print).with('test2...')
        subject.should_receive(:puts).with('finally')

        subject.format({:message => 'test', :type => 'inline', :complete => 'done'}, lambda { })
        subject.format({:message => 'test2', :type => 'inline', :complete => 'finally'}, lambda { })
      end

      it 'performs another wrapped report to ensure defaul behavior' do
        subject.should_receive(:puts).with('test')
        subject.should_receive(:puts).with('complete')
        subject.should_receive(:puts).with('test2')
        subject.should_receive(:puts).with('complete')

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
        subject.should_receive(:puts).with('test')
        subject.should_receive(:puts).with('  test2')
        subject.should_receive(:puts).with('  complete')
        subject.should_receive(:puts).with('complete')

        subject.format({:message => 'test'}, lambda {
          subject.format({:message => 'test2'}, lambda {})
        })
      end

      it 'indents the nested wrapped messages and outputs color' do
        subject.should_receive(:puts).with("#{controls[:red]}test#{controls[:clear]}")
        subject.should_receive(:puts).with("#{controls[:red]}  test2#{controls[:clear]}")
        subject.should_receive(:puts).with("#{controls[:red]}  complete#{controls[:clear]}")
        subject.should_receive(:puts).with("#{controls[:red]}complete#{controls[:clear]}")

        subject.format({:message => 'test', :color => 'red'}, lambda {
          subject.format({:message => 'test2', :color => 'red'}, lambda {})
        })
      end

      it 'indents the nested wrapped messages and outputs bold' do
        subject.should_receive(:puts).with("#{controls[:bold]}test#{controls[:clear]}")
        subject.should_receive(:puts).with("#{controls[:bold]}  test2#{controls[:clear]}")
        subject.should_receive(:puts).with("#{controls[:bold]}  complete#{controls[:clear]}")
        subject.should_receive(:puts).with("#{controls[:bold]}complete#{controls[:clear]}")

        subject.format({:message => 'test', :bold => true}, lambda {
          subject.format({:message => 'test2', :bold => true}, lambda {})
        })
      end

      it 'indents the multiple nested wrapped messages' do
        subject.should_receive(:puts).with('test')
        subject.should_receive(:puts).with('  test2')
        subject.should_receive(:puts).with('    test3')
        subject.should_receive(:puts).with('    complete')
        subject.should_receive(:puts).with('  complete')
        subject.should_receive(:puts).with('complete')

        subject.format({:message => 'test'}, lambda {
          subject.format({:message => 'test2'}, lambda {
            subject.format({:message => 'test3'}, lambda { })
          })
        })
      end

      it 'indents the nested wrapped and inline messages' do
        subject.should_receive(:puts).with('test')
        subject.should_receive(:print).with('  test2...')
        subject.should_receive(:puts).with('complete')
        subject.should_receive(:puts).with('complete')

        subject.format({:message => 'test'}, lambda {
          subject.format({:message => 'test2', :type => 'inline'}, lambda { })
        })
      end

      it 'indents the multiple nested wrapped messages' do
        subject.should_receive(:puts).with('test')
        subject.should_receive(:puts).with('  test2')
        subject.should_receive(:print).with('    test3...')
        subject.should_receive(:puts).with('complete')
        subject.should_receive(:puts).with('  complete')
        subject.should_receive(:puts).with('complete')

        subject.format({:message => 'test'}, lambda {
          subject.format({:message => 'test2'}, lambda {
            subject.format({:message => 'test3', :type => 'inline'}, lambda { })
          })
        })
      end

      it 'overrides the indent spacing of all messages' do
        subject.should_receive(:puts).with('test')
        subject.should_receive(:puts).with('    test2')
        subject.should_receive(:print).with('        test3...')
        subject.should_receive(:puts).with('complete')
        subject.should_receive(:puts).with('    complete')
        subject.should_receive(:puts).with('complete')

        subject.indent_size = 4

        subject.format({:message => 'test'}, lambda {
          subject.format({:message => 'test2'}, lambda {
            subject.format({:message => 'test3', :type => 'inline'}, lambda { })
          })
        })
      end

      it 'overrides the indent spacing of specific message' do
        subject.should_receive(:puts).with('test')
        subject.should_receive(:puts).with('      test2')
        subject.should_receive(:print).with('      test3...')
        subject.should_receive(:puts).with('complete')
        subject.should_receive(:puts).with('      complete')
        subject.should_receive(:puts).with('complete')

        subject.indent_size = 4

        subject.format({:message => 'test'}, lambda {
          subject.format({:message => 'test2', :indent_size => 6}, lambda {
            subject.format({:message => 'test3', :type => 'inline', :indent_size => 3}, lambda { })
          }) 
        })
      end

      it 'performs the sums specified in the block' do
        x,y,z = 0,0,0

        subject.should_receive(:puts).with('sum x and 10')
        subject.should_receive(:puts).with('  y is the difference of 20 and x')
        subject.should_receive(:puts).with('    z = x + y')
        subject.should_receive(:puts).with('    complete')
        subject.should_receive(:puts).with('  complete')
        subject.should_receive(:puts).with('complete')

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
