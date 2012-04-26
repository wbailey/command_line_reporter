require 'spec_helper'
require 'column'

describe CommandLineReporter::Column do
  describe '#initialize' do
    it 'rejects invalid options' do
      expect {
        CommandLineReporter::Column.new('test', :asdf => '1234')
      }.to raise_error ArgumentError
    end

    it 'defaults options hash' do
      expect {
        CommandLineReporter::Column.new('test')
      }.to_not raise_error
    end

    it 'defaults the width' do
      CommandLineReporter::Column.new('test').width.should == 10
    end

    it 'accepts the width' do
      CommandLineReporter::Column.new('test', :width => 50).width.should == 50
    end

    it 'requires valid width' do
      expect {
        CommandLineReporter::Column.new('test', :width => 'asdf')
      }.to raise_error ArgumentError
    end

    it 'accepts text' do
      CommandLineReporter::Column.new('asdf').text.should == 'asdf'
    end

    it 'accepts color' do
      CommandLineReporter::Column.new('asdf', :color => 'red').color.should == 'red'
    end

    it 'accepts bold' do
      CommandLineReporter::Column.new('asdf', :bold => true).bold.should be_true
    end

    it 'defaults the padding' do
      CommandLineReporter::Column.new('test').padding.should == 0
    end

    it 'accepts the padding' do
      CommandLineReporter::Column.new('test', :padding => 5).padding.should == 5
    end

    it 'requires valid width' do
      expect {
        CommandLineReporter::Column.new('test', :padding => 'asdf')
      }.to raise_error ArgumentError
    end
  end

  describe '#screen_rows' do
    let :controls do
      {
        :clear => "\e[0m",
        :bold => "\e[1m",
        :red => "\e[31m",
      }
    end

    context 'no wrapping' do
      context 'no padding' do
        it 'gives a single row' do
          c = CommandLineReporter::Column.new('x' * 5)
          c.screen_rows.size == 1
        end

        it 'handles empty text' do
          c = CommandLineReporter::Column.new
          c.screen_rows[0].should == ' ' * 10
        end

        context 'left justifies' do
          let(:text) { 'x' * 10 }
          let(:filler) { ' ' * 10 }

          it 'plain text' do
            c = CommandLineReporter::Column.new(text, :width => 20)
            c.screen_rows[0].should == text + filler
          end

          it 'outputs red' do
            c = CommandLineReporter::Column.new(text, :align => 'left', :width => 20, :color => 'red')
            c.screen_rows[0].should == controls[:red] + text + filler + controls[:clear]
          end

          it 'outputs bold' do
            c = CommandLineReporter::Column.new(text, :align => 'left', :width => 20, :bold => true)
            c.screen_rows[0].should == controls[:bold] + text + filler + controls[:clear]
          end
        end

        context 'right justifies' do
          let(:text) { 'x' * 10 }
          let(:filler) { ' ' * 10 }

          it 'plain text' do
            c = CommandLineReporter::Column.new(text, :align => 'right', :width => 20)
            c.screen_rows[0].should == filler + text
          end

          it 'outputs red' do
            c = CommandLineReporter::Column.new(text, :align => 'right', :width => 20, :color => 'red')
            c.screen_rows[0].should == controls[:red] + filler + text  + controls[:clear]
          end

          it 'outputs bold' do
            c = CommandLineReporter::Column.new(text, :align => 'right', :width => 20, :bold => true)
            c.screen_rows[0].should == controls[:bold] + filler + text + controls[:clear]
          end
        end

        context 'center justifies' do
          let(:text) { 'x' * 10 }
          let(:filler) { ' ' * 5 }

          it 'plain text' do
            c = CommandLineReporter::Column.new(text, :align => 'center', :width => 20)
            c.screen_rows[0].should == filler + text + filler
          end

          it 'outputs red' do
            c = CommandLineReporter::Column.new(text, :align => 'center', :width => 20, :color => 'red')
            c.screen_rows[0].should == controls[:red] + filler + text + filler + controls[:clear]
          end

          it 'outputs bold' do
            c = CommandLineReporter::Column.new(text, :align => 'center', :width => 20, :bold => true)
            c.screen_rows[0].should == controls[:bold] + filler + text + filler + controls[:clear]
          end
        end
      end

      context 'accounts for padding' do
        context 'left justifies' do
          let(:text) { 'x' * 10 }
          let(:padding) { ' ' * 5 }
          let(:filler) { ' ' * 10 }

          it 'plain text' do
            c = CommandLineReporter::Column.new(text, :padding => 5, :width => 30)
            c.screen_rows[0].should == padding + text + filler + padding
          end

          it 'outputs red' do
            c = CommandLineReporter::Column.new(text, :padding => 5, :width => 30, :color => 'red')
            c.screen_rows[0].should == padding + controls[:red] + text + filler + controls[:clear] + padding
          end

          it 'outputs bold' do
            c = CommandLineReporter::Column.new(text, :padding => 5, :width => 30, :bold => true)
            c.screen_rows[0].should == padding + controls[:bold] + text + filler + controls[:clear] + padding
          end
        end

        context 'right justifies' do
          let(:text) { 'x' * 10 }
          let(:padding) { ' ' * 5 }
          let(:filler) { ' ' * 10 }

          it 'plain text' do
            c = CommandLineReporter::Column.new(text, :align => 'right', :padding => 5, :width => 30)
            c.screen_rows[0].should == padding + filler + text + padding
          end

          it 'outputs red' do
            c = CommandLineReporter::Column.new(text, :align => 'right', :padding => 5, :width => 30, :color => 'red')
            c.screen_rows[0].should == padding + controls[:red] + filler + text + controls[:clear] + padding
          end

          it 'outputs bold' do
            c = CommandLineReporter::Column.new(text, :align => 'right', :padding => 5, :width => 30, :bold => true)
            c.screen_rows[0].should == padding + controls[:bold] + filler + text + controls[:clear] + padding
          end
        end

        context 'right justifies' do
          let(:text) { 'x' * 10 }
          let(:padding) { ' ' * 5 }
          let(:filler) { ' ' * 5 }

          it 'plain text' do
            c = CommandLineReporter::Column.new(text, :align => 'center', :padding => 5, :width => 30)
            c.screen_rows[0].should == padding + filler + text + filler + padding
          end

          it 'outputs red' do
            c = CommandLineReporter::Column.new(text, :align => 'center', :padding => 5, :width => 30, :color => 'red')
            c.screen_rows[0].should == padding + controls[:red] + filler + text + filler + controls[:clear] + padding
          end

          it 'outputs bold' do
            c = CommandLineReporter::Column.new(text, :align => 'center', :padding => 5, :width => 30, :bold => true)
            c.screen_rows[0].should == padding + controls[:bold] + filler + text + filler + controls[:clear] + padding
          end
        end
      end
    end

    context 'with wrapping' do
      context 'no padding' do
        context 'left justifies' do
          let(:text) { 'x' * 25 }
          let(:full_line) { 'x' * 10 }
          let(:remainder) { 'x' * 5 }
          let(:filler) { ' ' * 5 }

          it 'plain text' do
            c = CommandLineReporter::Column.new(text, :width => 10)
            c.screen_rows.should == [full_line, full_line, remainder + filler]
          end

          it 'outputs red' do
            c = CommandLineReporter::Column.new(text, :width => 10, :color => 'red')
            c.screen_rows.should == [
              controls[:red] + full_line + controls[:clear],
              controls[:red] + full_line + controls[:clear],
              controls[:red] + remainder + filler + controls[:clear],
            ]
          end

          it 'outputs bold' do
            c = CommandLineReporter::Column.new(text, :width => 10, :bold => true)
            c.screen_rows.should == [
              controls[:bold] + full_line + controls[:clear],
              controls[:bold] + full_line + controls[:clear],
              controls[:bold] + remainder + filler + controls[:clear],
            ]
          end
        end

        context 'right justifies' do
          let(:text) { 'x' * 25 }
          let(:full_line) { 'x' * 10 }
          let(:remainder) { 'x' * 5 }
          let(:filler) { ' ' * 5 }

          it 'plain text' do
            c = CommandLineReporter::Column.new(text, :align => 'right', :width => 10)
            c.screen_rows.should == [full_line, full_line, filler + remainder]
          end

          it 'outputs red' do
            c = CommandLineReporter::Column.new(text, :align => 'right', :width => 10, :color => 'red')
            c.screen_rows.should == [
              controls[:red] + full_line + controls[:clear],
              controls[:red] + full_line + controls[:clear],
              controls[:red] + filler + remainder + controls[:clear],
            ]
          end

          it 'outputs bold' do
            c = CommandLineReporter::Column.new(text, :align => 'right', :width => 10, :bold => true)
            c.screen_rows.should == [
              controls[:bold] + full_line + controls[:clear],
              controls[:bold] + full_line + controls[:clear],
              controls[:bold] + filler + remainder + controls[:clear],
            ]
          end
        end

        context 'center justifies' do
          let(:text) { 'x' * 25 }
          let(:full_line) { 'x' * 10 }
          let(:remainder) { 'x' * 5 }
          let(:left_filler) { ' ' * 3 }
          let(:right_filler) { ' ' * 2 }

          it 'plain text' do
            c = CommandLineReporter::Column.new(text, :align => 'center', :width => 10)
            c.screen_rows.should == [full_line, full_line, ' ' * 3 + remainder + right_filler]
          end

          it 'outputs red' do
            c = CommandLineReporter::Column.new(text, :align => 'center', :width => 10, :color => 'red')
            c.screen_rows.should == [
              controls[:red] + full_line + controls[:clear],
              controls[:red] + full_line + controls[:clear],
              controls[:red] + left_filler + remainder + right_filler + controls[:clear],
            ]
          end

          it 'outputs bold' do
            c = CommandLineReporter::Column.new(text, :align => 'center', :width => 10, :bold => true)
            c.screen_rows.should == [
              controls[:bold] + full_line + controls[:clear],
              controls[:bold] + full_line + controls[:clear],
              controls[:bold] + left_filler + remainder + right_filler + controls[:clear],
            ]
          end
        end
      end

      context 'account for padding' do
        context 'left justifies' do
          let(:text) { 'x' * 25 }
          let(:full_line) { 'x' * 16 }
          let(:remainder) { 'x' * 9 }
          let(:padding) { ' ' * 2 }
          let(:filler) { ' ' * 7 }

          it 'plain text' do
            c = CommandLineReporter::Column.new(text, :padding => 2, :width => 20)
            c.screen_rows.should == [
              padding + full_line + padding,
              padding + remainder + filler + padding,
            ]
          end

          it 'outputs red' do
            c = CommandLineReporter::Column.new(text, :padding => 2, :width => 20, :color => 'red')
            c.screen_rows.should == [
              padding + controls[:red] + full_line + controls[:clear] + padding,
              padding + controls[:red] + remainder + filler + controls[:clear] + padding,
            ]
          end

          it 'outputs bold' do
            c = CommandLineReporter::Column.new(text, :padding => 2, :width => 20, :bold => true)
            c.screen_rows.should == [
              padding + controls[:bold] + full_line + controls[:clear] + padding,
              padding + controls[:bold] + remainder + filler + controls[:clear] + padding,
            ]
          end
        end

        context 'right justifies' do
          let(:text) { 'x' * 25 }
          let(:full_line) { 'x' * 16 }
          let(:remainder) { 'x' * 9 }
          let(:padding) { ' ' * 2 }
          let(:filler) { ' ' * 7 }

          it 'plain text' do
            c = CommandLineReporter::Column.new(text, :padding => 2, :align => 'right', :width => 20)
            c.screen_rows.should == [
              padding + full_line + padding,
              padding + filler + remainder + padding,
            ]
          end

          it 'outputs red' do
            c = CommandLineReporter::Column.new(text, :align => 'right', :padding => 2, :width => 20, :color => 'red')
            c.screen_rows.should == [
              padding + controls[:red] + full_line + controls[:clear] + padding,
              padding + controls[:red] + filler + remainder + controls[:clear] + padding,
            ]
          end

          it 'outputs bold' do
            c = CommandLineReporter::Column.new(text, :align => 'right', :padding => 2, :width => 20, :bold => true)
            c.screen_rows.should == [
              padding + controls[:bold] + full_line + controls[:clear] + padding,
              padding + controls[:bold] + filler + remainder + controls[:clear] + padding,
            ]
          end
        end

        context 'center justifies' do
          let(:text) { 'x' * 25 }
          let(:full_line) { 'x' * 16 }
          let(:remainder) { 'x' * 9 }
          let(:padding) { ' ' * 2 }
          let(:left_filler) { ' ' * 4 }
          let(:right_filler) { ' ' * 3 }

          it 'plain text' do
            c = CommandLineReporter::Column.new(text, :padding => 2, :align => 'center', :width => 20)
            c.screen_rows.should == [
              padding + full_line + padding,
              padding + left_filler + remainder + right_filler + padding,
            ]
          end

          it 'outputs red' do
            c = CommandLineReporter::Column.new(text, :padding => 2, :align => 'center', :width => 20, :color => 'red')
            c.screen_rows.should == [
              padding + controls[:red] + full_line + controls[:clear] + padding,
              padding + controls[:red] + left_filler + remainder + right_filler + controls[:clear] + padding,
            ]
          end

          it 'outputs bold' do
            c = CommandLineReporter::Column.new(text, :padding => 2, :align => 'center', :width => 20, :bold => true)
            c.screen_rows.should == [
              padding + controls[:bold] + full_line + controls[:clear] + padding,
              padding + controls[:bold] + left_filler + remainder + right_filler + controls[:clear] + padding,
            ]
          end
        end
      end
    end
  end
end
