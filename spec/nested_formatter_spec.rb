require 'spec_helper'

describe CommandLineReporter::NestedFormatter do
  subject { CommandLineReporter::NestedFormatter.instance }

  let(:controls) do
    {
      clear: "\e[0m",
      bold: "\e[1m",
      red: "\e[31m"
    }
  end

  describe '#method default values' do
    describe '#message_string' do
      subject { super().message_string }
      it { should == 'working' }
    end

    describe '#complete_string' do
      subject { super().complete_string }
      it { should == 'complete' }
    end

    describe '#indent_size' do
      subject { super().indent_size }
      it { should eq 2 }
    end
  end

  describe '#format' do
    context 'argument validation' do
      before :each do
        @indent_size = subject.indent_size
      end

      # Restore the singleton to its original state to ensure clean tests
      after :each do
        subject.indent_size = @indent_size
      end

      it 'raises exception when there is an invalid argument' do
        expect do
          subject.format({ asdf: true }, -> {})
        end.to raise_exception ArgumentError
      end

      it 'raises an exception when a block is not given' do
        expect do
          subject.format(message: 'test')
        end.to raise_exception
      end

      it 'accepts valid arguments' do
        expect(subject).to receive(:puts).with('test')
        expect(subject).to receive(:puts).with('complete')

        expect do
          subject.format({ message: 'test' }, -> {}) do
          end
        end.not_to raise_exception
      end
    end

    context 'not nested' do
      before :each do
        @complete_string = subject.complete_string
        @indent_size = subject.indent_size
      end

      # Restore the singleton to its original state to ensure clean tests
      after :each do
        subject.complete_string = @complete_string
        subject.indent_size = @indent_size
      end

      it 'performs a wrapped report' do
        expect(subject).to receive(:puts).with('working')
        expect(subject).to receive(:puts).with('complete')

        subject.format({}, -> {})
      end

      it 'performs a wrapped report with color' do
        expect(subject).to receive(:puts).with("#{controls[:red]}working#{controls[:clear]}")
        expect(subject).to receive(:puts).with("#{controls[:red]}complete#{controls[:clear]}")

        subject.format({ color: 'red' }, -> {})
      end

      it 'performs a wrapped report with color' do
        expect(subject).to receive(:puts).with("#{controls[:bold]}working#{controls[:clear]}")
        expect(subject).to receive(:puts).with("#{controls[:bold]}complete#{controls[:clear]}")

        subject.format({ bold: true }, -> {})
      end

      it 'performs a wrapped report overriding the message' do
        expect(subject).to receive(:puts).with('test')
        expect(subject).to receive(:puts).with('complete')

        subject.format({ message: 'test' }, -> {})
      end

      it 'performs an inline report' do
        expect(subject).to receive(:print).with('test...')
        expect(subject).to receive(:puts).with('complete')
        expect(subject).to receive(:print).with('test2...')
        expect(subject).to receive(:puts).with('complete')

        subject.format({ message: 'test', type: 'inline' }, -> {})
        subject.format({ message: 'test2', type: 'inline' }, -> {})
      end

      it 'overrides the default for all invocations of a wrapped report' do
        subject.complete_string = 'done'
        expect(subject).to receive(:puts).with('test')
        expect(subject).to receive(:puts).with('done')
        expect(subject).to receive(:puts).with('test2')
        expect(subject).to receive(:puts).with('done')

        subject.format({ message: 'test' }, -> {})
        subject.format({ message: 'test2' }, -> {})
      end

      it 'overrides the default complete string for a wrapped report' do
        expect(subject).to receive(:puts).with('test')
        expect(subject).to receive(:puts).with('done')
        expect(subject).to receive(:puts).with('test2')
        expect(subject).to receive(:puts).with('finally')

        subject.format({ message: 'test', complete: 'done' }, -> {})
        subject.format({ message: 'test2', complete: 'finally' }, -> {})
      end

      it 'overrides the default complete string for an inline report' do
        expect(subject).to receive(:print).with('test...')
        expect(subject).to receive(:puts).with('done')
        expect(subject).to receive(:print).with('test2...')
        expect(subject).to receive(:puts).with('finally')

        subject.format({ message: 'test', type: 'inline', complete: 'done' }, -> {})
        subject.format({ message: 'test2', type: 'inline', complete: 'finally' }, -> {})
      end

      it 'performs another wrapped report to ensure defaul behavior' do
        expect(subject).to receive(:puts).with('test')
        expect(subject).to receive(:puts).with('complete')
        expect(subject).to receive(:puts).with('test2')
        expect(subject).to receive(:puts).with('complete')

        subject.format({ message: 'test' }, -> {})
        subject.format({ message: 'test2' }, -> {})
      end
    end

    context 'nested commands' do
      before :each do
        @indent_size = subject.indent_size
      end

      # Restore the singleton to its original state to ensure clean tests
      after :each do
        subject.indent_size = @indent_size
      end

      it 'indents the nested wrapped messages' do
        expect(subject).to receive(:puts).with('test')
        expect(subject).to receive(:puts).with('  test2')
        expect(subject).to receive(:puts).with('  complete')
        expect(subject).to receive(:puts).with('complete')

        subject.format({ message: 'test' }, lambda do
          subject.format({ message: 'test2' }, -> {})
        end)
      end

      it 'indents the nested wrapped messages and outputs color' do
        expect(subject).to receive(:puts).with("#{controls[:red]}test#{controls[:clear]}")
        expect(subject).to receive(:puts).with("#{controls[:red]}  test2#{controls[:clear]}")
        expect(subject).to receive(:puts).with("#{controls[:red]}  complete#{controls[:clear]}")
        expect(subject).to receive(:puts).with("#{controls[:red]}complete#{controls[:clear]}")

        subject.format({ message: 'test', color: 'red' }, lambda do
          subject.format({ message: 'test2', color: 'red' }, -> {})
        end)
      end

      it 'indents the nested wrapped messages and outputs bold' do
        expect(subject).to receive(:puts).with("#{controls[:bold]}test#{controls[:clear]}")
        expect(subject).to receive(:puts).with("#{controls[:bold]}  test2#{controls[:clear]}")
        expect(subject).to receive(:puts).with("#{controls[:bold]}  complete#{controls[:clear]}")
        expect(subject).to receive(:puts).with("#{controls[:bold]}complete#{controls[:clear]}")

        subject.format({ message: 'test', bold: true }, lambda do
          subject.format({ message: 'test2', bold: true }, -> {})
        end)
      end

      it 'indents the multiple nested wrapped messages' do
        expect(subject).to receive(:puts).with('test')
        expect(subject).to receive(:puts).with('  test2')
        expect(subject).to receive(:puts).with('    test3')
        expect(subject).to receive(:puts).with('    complete')
        expect(subject).to receive(:puts).with('  complete')
        expect(subject).to receive(:puts).with('complete')

        subject.format({ message: 'test' }, lambda do
          subject.format({ message: 'test2' }, lambda do
            subject.format({ message: 'test3' }, -> {})
          end)
        end)
      end

      it 'indents the nested wrapped and inline messages' do
        expect(subject).to receive(:puts).with('test')
        expect(subject).to receive(:print).with('  test2...')
        expect(subject).to receive(:puts).with('complete')
        expect(subject).to receive(:puts).with('complete')

        subject.format({ message: 'test' }, lambda do
          subject.format({ message: 'test2', type: 'inline' }, -> {})
        end)
      end

      it 'indents the multiple nested wrapped messages' do
        expect(subject).to receive(:puts).with('test')
        expect(subject).to receive(:puts).with('  test2')
        expect(subject).to receive(:print).with('    test3...')
        expect(subject).to receive(:puts).with('complete')
        expect(subject).to receive(:puts).with('  complete')
        expect(subject).to receive(:puts).with('complete')

        subject.format({ message: 'test' }, lambda do
          subject.format({ message: 'test2' }, lambda do
            subject.format({ message: 'test3', type: 'inline' }, -> {})
          end)
        end)
      end

      it 'overrides the indent spacing of all messages' do
        expect(subject).to receive(:puts).with('test')
        expect(subject).to receive(:puts).with('    test2')
        expect(subject).to receive(:print).with('        test3...')
        expect(subject).to receive(:puts).with('complete')
        expect(subject).to receive(:puts).with('    complete')
        expect(subject).to receive(:puts).with('complete')

        subject.indent_size = 4

        subject.format({ message: 'test' }, lambda do
          subject.format({ message: 'test2' }, lambda do
            subject.format({ message: 'test3', type: 'inline' }, -> {})
          end)
        end)
      end

      it 'overrides the indent spacing of specific message' do
        expect(subject).to receive(:puts).with('test')
        expect(subject).to receive(:puts).with('      test2')
        expect(subject).to receive(:print).with('      test3...')
        expect(subject).to receive(:puts).with('complete')
        expect(subject).to receive(:puts).with('      complete')
        expect(subject).to receive(:puts).with('complete')

        subject.indent_size = 4

        subject.format({ message: 'test' }, lambda do
          subject.format({ message: 'test2', indent_size: 6 }, lambda do
            subject.format({ message: 'test3', type: 'inline', indent_size: 3 }, -> {})
          end)
        end)
      end

      it 'performs the sums specified in the block' do
        x, y, z = 0, 0, 0

        expect(subject).to receive(:puts).with('sum x and 10')
        expect(subject).to receive(:puts).with('  y is the difference of 20 and x')
        expect(subject).to receive(:puts).with('    z = x + y')
        expect(subject).to receive(:puts).with('    complete')
        expect(subject).to receive(:puts).with('  complete')
        expect(subject).to receive(:puts).with('complete')

        subject.format({ message: 'sum x and 10' }, lambda do
          x += 10
          subject.format({ message: 'y is the difference of 20 and x' }, lambda do
            y = 20 - x
            subject.format({ message: 'z = x + y' }, lambda do
              z = x + y
            end)
          end)
        end)

        expect(x).to eq(10)
        expect(y).to eq(10)
        expect(z).to eq(20)
      end
    end
  end
end
