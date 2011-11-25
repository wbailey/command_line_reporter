$: << File.join(File.dirname(__FILE__), '..', 'lib')
require 'command_line_reporter'

describe CommandLineReporter do
  let :use_class do
    Class.new do
      include CommandLineReporter
    end
  end

  subject { use_class.new }

  describe 'default values' do
    its(:clr_indent) { should be_nil }
    its(:clr_message_string) { should == 'working' }
    its(:clr_complete_string) { should == 'complete' }
    its(:clr_indent_size) { should eq 2 }
  end

  describe "#report" do
    context 'progress formatter' do
      before :each do
        subject.clr_formatter = 'progress'
      end

      it 'displays dots for progress' do
        subject.should_receive(:print).exactly(10).times.with('.')
        subject.report do
          10.times {progress}
        end
      end
    end

    context 'nested formatter' do
      before :each do
        subject.clr_formatter = 'nested'
      end

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

      context 'not nested' do
        it 'performs a wrapped report' do
          subject.should_receive(:puts).with('working')
          subject.should_receive(:puts).with('complete')

          subject.report() { }
        end

        it 'performs a wrapped report overriding the message' do
          subject.should_receive(:puts).with('test')
          subject.should_receive(:puts).with('complete')

          subject.report(:message => 'test') { }
        end

        it 'performs an inline report' do
          subject.should_receive(:print).with('test...')
          subject.should_receive(:puts).with('complete')
          subject.should_receive(:print).with('test2...')
          subject.should_receive(:puts).with('complete')

          subject.report(:message => 'test', :type => 'inline') { }
          subject.report(:message => 'test2', :type => 'inline') { }
        end

        it 'overrides the default for all invocations of a wrapped report' do
          subject.clr_complete_string = 'done'
          subject.should_receive(:puts).with('test')
          subject.should_receive(:puts).with('done')
          subject.should_receive(:puts).with('test2')
          subject.should_receive(:puts).with('done')

          subject.report(:message => 'test') { }
          subject.report(:message => 'test2') { }
        end

        it 'overrides the default complete string for a wrapped report' do
          subject.should_receive(:puts).with('test')
          subject.should_receive(:puts).with('done')
          subject.should_receive(:puts).with('test2')
          subject.should_receive(:puts).with('finally')

          subject.report(:message => 'test', :complete => 'done') { }
          subject.report(:message => 'test2', :complete => 'finally') { }

          subject.clr_indent.should == -1
        end

        it 'overrides the default complete string for an inline report' do
          subject.should_receive(:print).with('test...')
          subject.should_receive(:puts).with('done')
          subject.should_receive(:print).with('test2...')
          subject.should_receive(:puts).with('finally')

          subject.report(:message => 'test', :type => 'inline', :complete => 'done') { }
          subject.report(:message => 'test2', :type => 'inline', :complete => 'finally') { }

          subject.clr_indent.should == -1
        end

        it 'performs another wrapped report to ensure defaul behavior' do
          subject.should_receive(:puts).with('test')
          subject.should_receive(:puts).with('complete')
          subject.should_receive(:puts).with('test2')
          subject.should_receive(:puts).with('complete')

          subject.report(:message => 'test') { }
          subject.report(:message => 'test2') { }
        end
      end

      context 'nested commands' do
        it 'indents the nested wrapped messages' do
          subject.should_receive(:puts).with('test')
          subject.should_receive(:puts).with('  test2')
          subject.should_receive(:puts).with('  complete')
          subject.should_receive(:puts).with('complete')

          subject.report(:message => 'test') do
            subject.report(:message => 'test2') { }
          end
        end

        it 'indents the multiple nested wrapped messages' do
          subject.should_receive(:puts).with('test')
          subject.should_receive(:puts).with('  test2')
          subject.should_receive(:puts).with('    test3')
          subject.should_receive(:puts).with('    complete')
          subject.should_receive(:puts).with('  complete')
          subject.should_receive(:puts).with('complete')

          subject.report(:message => 'test') do
            subject.report(:message => 'test2') do
              subject.report(:message => 'test3') do
              end
            end
          end
        end

        it 'indents the nested wrapped and inline messages' do
          subject.should_receive(:puts).with('test')
          subject.should_receive(:print).with('  test2...')
          subject.should_receive(:puts).with('complete')
          subject.should_receive(:puts).with('complete')

          subject.report(:message => 'test') do
            subject.report(:message => 'test2', :type => 'inline') { }
          end
        end

        it 'indents the multiple nested wrapped messages' do
          subject.should_receive(:puts).with('test')
          subject.should_receive(:puts).with('  test2')
          subject.should_receive(:print).with('    test3...')
          subject.should_receive(:puts).with('complete')
          subject.should_receive(:puts).with('  complete')
          subject.should_receive(:puts).with('complete')

          subject.report(:message => 'test') do
            subject.report(:message => 'test2') do
              subject.report(:message => 'test3', :type => 'inline') do
              end
            end
          end
        end

        it 'overrides the indent spacing of all messages' do
          subject.should_receive(:puts).with('test')
          subject.should_receive(:puts).with('    test2')
          subject.should_receive(:print).with('        test3...')
          subject.should_receive(:puts).with('complete')
          subject.should_receive(:puts).with('    complete')
          subject.should_receive(:puts).with('complete')

          subject.clr_indent_size = 4

          subject.report(:message => 'test') do
            subject.report(:message => 'test2') do
              subject.report(:message => 'test3', :type => 'inline') do
              end
            end
          end
        end
        it 'overrides the indent spacing of specific message' do
          subject.should_receive(:puts).with('test')
          subject.should_receive(:puts).with('      test2')
          subject.should_receive(:print).with('      test3...')
          subject.should_receive(:puts).with('complete')
          subject.should_receive(:puts).with('      complete')
          subject.should_receive(:puts).with('complete')

          subject.clr_indent_size = 4

          subject.report(:message => 'test') do
            subject.report(:message => 'test2', :indent_size => 6) do
              subject.report(:message => 'test3', :type => 'inline', :indent_size => 3) do
              end
            end
          end
        end
      end
    end
  end
end
