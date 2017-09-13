require 'spec_helper'

describe CommandLineReporter::Column do
  subject { CommandLineReporter::Column }

  def screen_rows(args = {})
    described_class.new(text, {width: 5}.merge(args)).screen_rows
  end

  context '#initialize' do
    it 'rejects invalid options' do
      expect do
        subject.new('test', asdf: '1234')
      end.to raise_error ArgumentError
    end

    it 'defaults options hash' do
      expect do
        subject.new('test')
      end.to_not raise_error Exception
    end

    it 'defaults the width' do
      c = subject.new('test')
      expect(c.width).to eq(10)
    end

    it 'accepts the width' do
      c = subject.new('test', width: 50)
      expect(c.width).to eq(50)
    end

    it 'requires valid width' do
      expect do
        subject.new('test', width: 'asdf')
      end.to raise_error ArgumentError
    end

    it 'accepts text' do
      c = subject.new('asdf')
      expect(c.text).to eq('asdf')
    end

    it 'accepts color' do
      c = subject.new('asdf', color: 'red')
      expect(c.color).to eq('red')
    end

    it 'accepts bold' do
      c = subject.new('asdf', bold: true)
      expect(c.bold).to be true
    end

    it 'defaults the padding' do
      c = subject.new('test')
      expect(c.padding).to eq(0)
    end

    it 'accepts the padding' do
      c = subject.new('test', padding: 5)
      expect(c.padding).to eq(5)
    end

    it 'requires valid width' do
      expect do
        subject.new('test', padding: 'asdf')
      end.to raise_error ArgumentError
    end
  end

  context '#size' do
    it 'should have default width' do
      c = subject.new('test')
      expect(c.size).to eq(10)
    end

    it 'should have custom width' do
      c = subject.new('test', width: 5)
      expect(c.size).to eq(5)
    end

    it 'should be reduced by the padding' do
      c = subject.new('test', width: 5, padding: 1)
      expect(c.size).to eq(3)
    end
  end

  context '#required_width' do
    it 'is the length of the text plus twice the padding' do
      c = subject.new('test')
      expect(c.required_width).to eq(4)
    end

    it 'should be length of string plus twice default padding' do
      c = subject.new('test', padding: 1)
      expect(c.required_width).to eq(6)
    end

    it 'should be length of string plus twice custom padding' do
      c = subject.new('test', padding: 5)
      expect(c.required_width).to eq(14)
    end
  end

  context 'spanning columns' do
    it 'should adjust width for 2 default columns' do
      col = subject.new('test', span: 2)
      expect(col.width).to eq(20)
      expect(col.size).to eq(23)
    end

    it 'should adjust width for 2 custom sized columns' do
      col = subject.new('test', width: 20, span: 2)
      expect(col.width).to eq(40)
      expect(col.size).to eq(43)
    end

    it 'should adjust width for 3 default columns' do
      col = subject.new('test', span: 3)
      expect(col.width).to eq(30)
      expect(col.size).to eq(36)
    end

    it 'should adjust width for 3 custom sized columns' do
      col = subject.new('test', width: 20, span: 3)
      expect(col.width).to eq(60)
      expect(col.size).to eq(66)
    end

    it 'should adjust width for 4 default columns' do
      col = subject.new('test', span: 4)
      expect(col.width).to eq(40)
      expect(col.size).to eq(49)
    end

    it 'should adjust width for 2 custom sized columns' do
      col = subject.new('test', width: 20, span: 4)
      expect(col.width).to eq(80)
      expect(col.size).to eq(89)
    end
  end

  context '#screen_rows' do
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
          c = subject.new('x' * 5)
          c.screen_rows.size == 1
        end

        it 'handles empty text' do
          c = subject.new
          expect(c.screen_rows[0]).to eq(' ' * 10)
        end

        context 'left justifies' do
          let(:text) { 'x' * 10 }
          let(:filler) { ' ' * 10 }

          it 'plain text' do
            c = subject.new(text, width: 20)
            expect(c.screen_rows[0]).to eq(text + filler)
          end

          it 'outputs red' do
            c = subject.new(text, align: 'left', width: 20, color: 'red')
            expect(c.screen_rows[0]).to eq(controls[:red] + text + filler + controls[:clear])
          end

          it 'outputs bold' do
            c = subject.new(text, align: 'left', width: 20, bold: true)
            expect(c.screen_rows[0]).to eq(controls[:bold] + text + filler + controls[:clear])
          end
        end

        context 'right justifies' do
          let(:text) { 'x' * 10 }
          let(:filler) { ' ' * 10 }

          it 'plain text' do
            c = subject.new(text, align: 'right', width: 20)
            expect(c.screen_rows[0]).to eq(filler + text)
          end

          it 'outputs red' do
            c = subject.new(text, align: 'right', width: 20, color: 'red')
            expect(c.screen_rows[0]).to eq(controls[:red] + filler + text + controls[:clear])
          end

          it 'outputs bold' do
            c = subject.new(text, align: 'right', width: 20, bold: true)
            expect(c.screen_rows[0]).to eq(controls[:bold] + filler + text + controls[:clear])
          end
        end

        context 'center justifies' do
          let(:text) { 'x' * 10 }
          let(:filler) { ' ' * 5 }

          it 'plain text' do
            c = subject.new(text, align: 'center', width: 20)
            expect(c.screen_rows[0]).to eq(filler + text + filler)
          end

          it 'outputs red' do
            c = subject.new(text, align: 'center', width: 20, color: 'red')
            expect(c.screen_rows[0]).to eq(controls[:red] + filler + text + filler + controls[:clear])
          end

          it 'outputs bold' do
            c = subject.new(text, align: 'center', width: 20, bold: true)
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
            c = subject.new(text, padding: 5, width: 30)
            expect(c.screen_rows[0]).to eq(padding + text + filler + padding)
          end

          it 'outputs red' do
            c = subject.new(text, padding: 5, width: 30, color: 'red')
            expect(c.screen_rows[0]).to eq(padding + controls[:red] + text + filler + controls[:clear] + padding)
          end

          it 'outputs bold' do
            c = subject.new(text, padding: 5, width: 30, bold: true)
            expect(c.screen_rows[0]).to eq(padding + controls[:bold] + text + filler + controls[:clear] + padding)
          end
        end

        context 'right justifies' do
          let(:text) { 'x' * 10 }
          let(:padding) { ' ' * 5 }
          let(:filler) { ' ' * 10 }

          it 'plain text' do
            c = subject.new(text, align: 'right', padding: 5, width: 30)
            expect(c.screen_rows[0]).to eq(padding + filler + text + padding)
          end

          it 'outputs red' do
            c = subject.new(text, align: 'right', padding: 5, width: 30, color: 'red')
            expect(c.screen_rows[0]).to eq(padding + controls[:red] + filler + text + controls[:clear] + padding)
          end

          it 'outputs bold' do
            c = subject.new(text, align: 'right', padding: 5, width: 30, bold: true)
            expect(c.screen_rows[0]).to eq(padding + controls[:bold] + filler + text + controls[:clear] + padding)
          end
        end

        context 'right justifies' do
          let(:text) { 'x' * 10 }
          let(:padding) { ' ' * 5 }
          let(:filler) { ' ' * 5 }

          it 'plain text' do
            c = subject.new(text, align: 'center', padding: 5, width: 30)
            expect(c.screen_rows[0]).to eq(padding + filler + text + filler + padding)
          end

          it 'outputs red' do
            c = subject.new(text, align: 'center', padding: 5, width: 30, color: 'red')
            expect(c.screen_rows[0]).to eq(padding + controls[:red] + filler + text + filler + controls[:clear] + padding)
          end

          it 'outputs bold' do
            c = subject.new(text, align: 'center', padding: 5, width: 30, bold: true)
            expect(c.screen_rows[0]).to eq(padding + controls[:bold] + filler + text + filler + controls[:clear] + padding)
          end
        end
      end
    end

    context 'with wrapping' do
      context 'no padding' do
        context 'left justifies' do
          let(:text) { "one cooperative\n\nbag copy" }

          describe 'line-breaks' do
            it 'do not break output' do
              expect(screen_rows(width: 20)).to eq(['one cooperative     ', ' ' * 20, 'bag copy            '])
            end
          end

          describe 'wrap: word' do
            it 'tries to break lines between words' do
              expect(screen_rows(wrap: :word)).to eq(['one  ', 'coope', 'rativ', 'e    ', '     ', 'bag  ', 'copy '])
            end
          end

          describe 'wrap: character' do
            it 'uses "character"-based wrapping by default' do
              expect(screen_rows).to eq(screen_rows(wrap: :character))
            end

            it 'ignores word-breaks' do
              expect(screen_rows).to eq(['one c', 'ooper', 'ative', '     ', '     ', 'bag c', 'opy  '])
            end
          end

          it 'outputs color' do
            screen_rows(color: 'red').each do |row|
              expect(row).to start_with(controls[:red])
              expect(row).to end_with(controls[:clear])
            end
          end

          it 'outputs bold' do
            screen_rows(bold: true).each do |row|
              expect(row).to start_with(controls[:bold])
              expect(row).to end_with(controls[:clear])
            end
          end
        end

        context 'right justifies' do
          let(:text) { 'x' * 25 }
          let(:full_line) { 'x' * 10 }
          let(:remainder) { 'x' * 5 }
          let(:filler) { ' ' * 5 }

          it 'plain text' do
            c = subject.new(text, align: 'right', width: 10)
            expect(c.screen_rows).to eq([full_line, full_line, filler + remainder])
          end

          it 'outputs red' do
            c = subject.new(text, align: 'right', width: 10, color: 'red')
            expect(c.screen_rows).to eq(
              [
                controls[:red] + full_line + controls[:clear],
                controls[:red] + full_line + controls[:clear],
                controls[:red] + filler + remainder + controls[:clear]
              ]
            )
          end

          it 'outputs bold' do
            c = subject.new(text, align: 'right', width: 10, bold: true)
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
            c = subject.new(text, align: 'center', width: 10)
            expect(c.screen_rows).to eq([full_line, full_line, ' ' * 3 + remainder + right_filler])
          end

          it 'outputs red' do
            c = subject.new(text, align: 'center', width: 10, color: 'red')
            expect(c.screen_rows).to eq(
              [
                controls[:red] + full_line + controls[:clear],
                controls[:red] + full_line + controls[:clear],
                controls[:red] + left_filler + remainder + right_filler + controls[:clear]
              ]
            )
          end

          it 'outputs bold' do
            c = subject.new(text, align: 'center', width: 10, bold: true)
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
            c = subject.new(text, padding: 2, width: 20)
            expect(c.screen_rows).to eq(
              [
                padding + full_line + padding,
                padding + remainder + filler + padding
              ]
            )
          end

          it 'outputs red' do
            c = subject.new(text, padding: 2, width: 20, color: 'red')
            expect(c.screen_rows).to eq(
              [
                padding + controls[:red] + full_line + controls[:clear] + padding,
                padding + controls[:red] + remainder + filler + controls[:clear] + padding
              ]
            )
          end

          it 'outputs bold' do
            c = subject.new(text, padding: 2, width: 20, bold: true)
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
            c = subject.new(text, padding: 2, align: 'right', width: 20)
            expect(c.screen_rows).to eq(
              [
                padding + full_line + padding,
                padding + filler + remainder + padding
              ]
            )
          end

          it 'outputs red' do
            c = subject.new(text, align: 'right', padding: 2, width: 20, color: 'red')
            expect(c.screen_rows).to eq(
              [
                padding + controls[:red] + full_line + controls[:clear] + padding,
                padding + controls[:red] + filler + remainder + controls[:clear] + padding
              ]
            )
          end

          it 'outputs bold' do
            c = subject.new(text, align: 'right', padding: 2, width: 20, bold: true)
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
            c = subject.new(text, padding: 2, align: 'center', width: 20)
            expect(c.screen_rows).to eq(
              [
                padding + full_line + padding,
                padding + left_filler + remainder + right_filler + padding
              ]
            )
          end

          it 'outputs red' do
            c = subject.new(text, padding: 2, align: 'center', width: 20, color: 'red')
            expect(c.screen_rows).to eq(
              [
                padding + controls[:red] + full_line + controls[:clear] + padding,
                padding + controls[:red] + left_filler + remainder + right_filler + controls[:clear] + padding
              ]
            )
          end

          it 'outputs bold' do
            c = subject.new(text, padding: 2, align: 'center', width: 20, bold: true)
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
