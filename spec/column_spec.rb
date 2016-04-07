require 'spec_helper'

describe CommandLineReporter::Column do
  describe '#initialize' do
    it 'rejects invalid options' do
      expect do
        CommandLineReporter::Column.new('test', asdf: '1234')
      end.to raise_error ArgumentError
    end

    it 'defaults options hash' do
      expect do
        CommandLineReporter::Column.new('test')
      end.to_not raise_error
    end

    it 'defaults the width' do
      expect(CommandLineReporter::Column.new('test').width).to eq(10)
    end

    it 'accepts the width' do
      expect(CommandLineReporter::Column.new('test', width: 50).width).to eq(50)
    end

    it 'requires valid width' do
      expect do
        CommandLineReporter::Column.new('test', width: 'asdf')
      end.to raise_error ArgumentError
    end

    it 'accepts text' do
      expect(CommandLineReporter::Column.new('asdf').text).to eq('asdf')
    end

    it 'accepts color' do
      expect(CommandLineReporter::Column.new('asdf', color: 'red').color).to eq('red')
    end

    it 'accepts bold' do
      expect(CommandLineReporter::Column.new('asdf', bold: true).bold).to be true
    end

    it 'defaults the padding' do
      expect(CommandLineReporter::Column.new('test').padding).to eq(0)
    end

    it 'accepts the padding' do
      expect(CommandLineReporter::Column.new('test', padding: 5).padding).to eq(5)
    end

    it 'requires valid width' do
      expect do
        CommandLineReporter::Column.new('test', padding: 'asdf')
      end.to raise_error ArgumentError
    end
  end

  describe '#size' do
    it 'is the width less twice the padding' do
      expect(CommandLineReporter::Column.new('test').size).to eq(10)
      expect(CommandLineReporter::Column.new('test', width: 5).size).to eq(5)
      expect(CommandLineReporter::Column.new('test', width: 5, padding: 1).size).to eq(3)
    end
  end

  describe '#required_width' do
    it 'is the length of the text plus twice the padding' do
      expect(CommandLineReporter::Column.new('test').required_width).to eq(4)
      expect(CommandLineReporter::Column.new('test', padding: 1).required_width).to eq(6)
      expect(CommandLineReporter::Column.new('test', padding: 5).required_width).to eq(14)
    end
  end

  describe '#screen_rows' do
    let :controls do
      {
        clear: "\e[0m",
        bold: "\e[1m",
        red: "\e[31m"
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
          expect(c.screen_rows[0]).to eq(' ' * 10)
        end

        context 'left justifies' do
          let(:text) { 'x' * 10 }
          let(:filler) { ' ' * 10 }

          it 'plain text' do
            c = CommandLineReporter::Column.new(text, width: 20)
            expect(c.screen_rows[0]).to eq(text + filler)
          end

          it 'outputs red' do
            c = CommandLineReporter::Column.new(text, align: 'left', width: 20, color: 'red')
            expect(c.screen_rows[0]).to eq(controls[:red] + text + filler + controls[:clear])
          end

          it 'outputs bold' do
            c = CommandLineReporter::Column.new(text, align: 'left', width: 20, bold: true)
            expect(c.screen_rows[0]).to eq(controls[:bold] + text + filler + controls[:clear])
          end
        end

        context 'right justifies' do
          let(:text) { 'x' * 10 }
          let(:filler) { ' ' * 10 }

          it 'plain text' do
            c = CommandLineReporter::Column.new(text, align: 'right', width: 20)
            expect(c.screen_rows[0]).to eq(filler + text)
          end

          it 'outputs red' do
            c = CommandLineReporter::Column.new(text, align: 'right', width: 20, color: 'red')
            expect(c.screen_rows[0]).to eq(controls[:red] + filler + text + controls[:clear])
          end

          it 'outputs bold' do
            c = CommandLineReporter::Column.new(text, align: 'right', width: 20, bold: true)
            expect(c.screen_rows[0]).to eq(controls[:bold] + filler + text + controls[:clear])
          end
        end

        context 'center justifies' do
          let(:text) { 'x' * 10 }
          let(:filler) { ' ' * 5 }

          it 'plain text' do
            c = CommandLineReporter::Column.new(text, align: 'center', width: 20)
            expect(c.screen_rows[0]).to eq(filler + text + filler)
          end

          it 'outputs red' do
            c = CommandLineReporter::Column.new(text, align: 'center', width: 20, color: 'red')
            expect(c.screen_rows[0]).to eq(controls[:red] + filler + text + filler + controls[:clear])
          end

          it 'outputs bold' do
            c = CommandLineReporter::Column.new(text, align: 'center', width: 20, bold: true)
            expect(c.screen_rows[0]).to eq(controls[:bold] + filler + text + filler + controls[:clear])
          end
        end
      end

      context 'accounts for padding' do
        context 'left justifies' do
          let(:text) { 'x' * 10 }
          let(:padding) { ' ' * 5 }
          let(:filler) { ' ' * 10 }

          it 'plain text' do
            c = CommandLineReporter::Column.new(text, padding: 5, width: 30)
            expect(c.screen_rows[0]).to eq(padding + text + filler + padding)
          end

          it 'outputs red' do
            c = CommandLineReporter::Column.new(text, padding: 5, width: 30, color: 'red')
            expect(c.screen_rows[0]).to eq(padding + controls[:red] + text + filler + controls[:clear] + padding)
          end

          it 'outputs bold' do
            c = CommandLineReporter::Column.new(text, padding: 5, width: 30, bold: true)
            expect(c.screen_rows[0]).to eq(padding + controls[:bold] + text + filler + controls[:clear] + padding)
          end
        end

        context 'right justifies' do
          let(:text) { 'x' * 10 }
          let(:padding) { ' ' * 5 }
          let(:filler) { ' ' * 10 }

          it 'plain text' do
            c = CommandLineReporter::Column.new(text, align: 'right', padding: 5, width: 30)
            expect(c.screen_rows[0]).to eq(padding + filler + text + padding)
          end

          it 'outputs red' do
            c = CommandLineReporter::Column.new(text, align: 'right', padding: 5, width: 30, color: 'red')
            expect(c.screen_rows[0]).to eq(padding + controls[:red] + filler + text + controls[:clear] + padding)
          end

          it 'outputs bold' do
            c = CommandLineReporter::Column.new(text, align: 'right', padding: 5, width: 30, bold: true)
            expect(c.screen_rows[0]).to eq(padding + controls[:bold] + filler + text + controls[:clear] + padding)
          end
        end

        context 'right justifies' do
          let(:text) { 'x' * 10 }
          let(:padding) { ' ' * 5 }
          let(:filler) { ' ' * 5 }

          it 'plain text' do
            c = CommandLineReporter::Column.new(text, align: 'center', padding: 5, width: 30)
            expect(c.screen_rows[0]).to eq(padding + filler + text + filler + padding)
          end

          it 'outputs red' do
            c = CommandLineReporter::Column.new(text, align: 'center', padding: 5, width: 30, color: 'red')
            expect(c.screen_rows[0]).to eq(padding + controls[:red] + filler + text + filler + controls[:clear] + padding)
          end

          it 'outputs bold' do
            c = CommandLineReporter::Column.new(text, align: 'center', padding: 5, width: 30, bold: true)
            expect(c.screen_rows[0]).to eq(padding + controls[:bold] + filler + text + filler + controls[:clear] + padding)
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
            c = CommandLineReporter::Column.new(text, width: 10)
            expect(c.screen_rows).to eq([full_line, full_line, remainder + filler])
          end

          it 'outputs red' do
            c = CommandLineReporter::Column.new(text, width: 10, color: 'red')
            expect(c.screen_rows).to eq(
              [
                controls[:red] + full_line + controls[:clear],
                controls[:red] + full_line + controls[:clear],
                controls[:red] + remainder + filler + controls[:clear]
              ]
            )
          end

          it 'outputs bold' do
            c = CommandLineReporter::Column.new(text, width: 10, bold: true)
            expect(c.screen_rows).to eq(
              [
                controls[:bold] + full_line + controls[:clear],
                controls[:bold] + full_line + controls[:clear],
                controls[:bold] + remainder + filler + controls[:clear]
              ]
            )
          end
        end

        context 'right justifies' do
          let(:text) { 'x' * 25 }
          let(:full_line) { 'x' * 10 }
          let(:remainder) { 'x' * 5 }
          let(:filler) { ' ' * 5 }

          it 'plain text' do
            c = CommandLineReporter::Column.new(text, align: 'right', width: 10)
            expect(c.screen_rows).to eq([full_line, full_line, filler + remainder])
          end

          it 'outputs red' do
            c = CommandLineReporter::Column.new(text, align: 'right', width: 10, color: 'red')
            expect(c.screen_rows).to eq(
              [
                controls[:red] + full_line + controls[:clear],
                controls[:red] + full_line + controls[:clear],
                controls[:red] + filler + remainder + controls[:clear]
              ]
            )
          end

          it 'outputs bold' do
            c = CommandLineReporter::Column.new(text, align: 'right', width: 10, bold: true)
            expect(c.screen_rows).to eq(
              [
                controls[:bold] + full_line + controls[:clear],
                controls[:bold] + full_line + controls[:clear],
                controls[:bold] + filler + remainder + controls[:clear]
              ]
            )
          end
        end

        context 'center justifies' do
          let(:text) { 'x' * 25 }
          let(:full_line) { 'x' * 10 }
          let(:remainder) { 'x' * 5 }
          let(:left_filler) { ' ' * 3 }
          let(:right_filler) { ' ' * 2 }

          it 'plain text' do
            c = CommandLineReporter::Column.new(text, align: 'center', width: 10)
            expect(c.screen_rows).to eq([full_line, full_line, ' ' * 3 + remainder + right_filler])
          end

          it 'outputs red' do
            c = CommandLineReporter::Column.new(text, align: 'center', width: 10, color: 'red')
            expect(c.screen_rows).to eq(
              [
                controls[:red] + full_line + controls[:clear],
                controls[:red] + full_line + controls[:clear],
                controls[:red] + left_filler + remainder + right_filler + controls[:clear]
              ]
            )
          end

          it 'outputs bold' do
            c = CommandLineReporter::Column.new(text, align: 'center', width: 10, bold: true)
            expect(c.screen_rows).to eq(
              [
                controls[:bold] + full_line + controls[:clear],
                controls[:bold] + full_line + controls[:clear],
                controls[:bold] + left_filler + remainder + right_filler + controls[:clear]
              ]
            )
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
            c = CommandLineReporter::Column.new(text, padding: 2, width: 20)
            expect(c.screen_rows).to eq(
              [
                padding + full_line + padding,
                padding + remainder + filler + padding
              ]
            )
          end

          it 'outputs red' do
            c = CommandLineReporter::Column.new(text, padding: 2, width: 20, color: 'red')
            expect(c.screen_rows).to eq(
              [
                padding + controls[:red] + full_line + controls[:clear] + padding,
                padding + controls[:red] + remainder + filler + controls[:clear] + padding
              ]
            )
          end

          it 'outputs bold' do
            c = CommandLineReporter::Column.new(text, padding: 2, width: 20, bold: true)
            expect(c.screen_rows).to eq(
              [
                padding + controls[:bold] + full_line + controls[:clear] + padding,
                padding + controls[:bold] + remainder + filler + controls[:clear] + padding
              ]
            )
          end
        end

        context 'right justifies' do
          let(:text) { 'x' * 25 }
          let(:full_line) { 'x' * 16 }
          let(:remainder) { 'x' * 9 }
          let(:padding) { ' ' * 2 }
          let(:filler) { ' ' * 7 }

          it 'plain text' do
            c = CommandLineReporter::Column.new(text, padding: 2, align: 'right', width: 20)
            expect(c.screen_rows).to eq(
              [
                padding + full_line + padding,
                padding + filler + remainder + padding
              ]
            )
          end

          it 'outputs red' do
            c = CommandLineReporter::Column.new(text, align: 'right', padding: 2, width: 20, color: 'red')
            expect(c.screen_rows).to eq(
              [
                padding + controls[:red] + full_line + controls[:clear] + padding,
                padding + controls[:red] + filler + remainder + controls[:clear] + padding
              ]
            )
          end

          it 'outputs bold' do
            c = CommandLineReporter::Column.new(text, align: 'right', padding: 2, width: 20, bold: true)
            expect(c.screen_rows).to eq(
              [
                padding + controls[:bold] + full_line + controls[:clear] + padding,
                padding + controls[:bold] + filler + remainder + controls[:clear] + padding
              ]
            )
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
            c = CommandLineReporter::Column.new(text, padding: 2, align: 'center', width: 20)
            expect(c.screen_rows).to eq(
              [
                padding + full_line + padding,
                padding + left_filler + remainder + right_filler + padding
              ]
            )
          end

          it 'outputs red' do
            c = CommandLineReporter::Column.new(text, padding: 2, align: 'center', width: 20, color: 'red')
            expect(c.screen_rows).to eq(
              [
                padding + controls[:red] + full_line + controls[:clear] + padding,
                padding + controls[:red] + left_filler + remainder + right_filler + controls[:clear] + padding
              ]
            )
          end

          it 'outputs bold' do
            c = CommandLineReporter::Column.new(text, padding: 2, align: 'center', width: 20, bold: true)
            expect(c.screen_rows).to eq(
              [
                padding + controls[:bold] + full_line + controls[:clear] + padding,
                padding + controls[:bold] + left_filler + remainder + right_filler + controls[:clear] + padding
              ]
            )
          end
        end
      end
    end
  end
end
