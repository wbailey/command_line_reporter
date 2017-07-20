require 'spec_helper'

describe CommandLineReporter::Table do
  subject { CommandLineReporter::Table }
  let(:row_subject) { CommandLineReporter::Row }
  let(:col_subject) { CommandLineReporter::Column }

  context 'creation' do
    it 'defaults options hash' do
      expect do
        subject.new
      end.to_not raise_error Exception
    end

    it 'defaults the border' do
      t = subject.new
      expect(t.border).to be false
    end

    it 'accepts the border' do
      t = subject.new(border: true)
      expect(t.border).to eq(true)
    end

    it 'output encoding should be ascii' do
      t = subject.new(encoding: :ascii)
      expect(t.encoding).to eq(:ascii)
    end

    it 'output encoding should be unicode' do
      t = subject.new
      expect(t.encoding).to eq(:unicode)
    end
  end

  context 'rows' do
    it 'allows addition' do
      cols = [col_subject.new('test1'), col_subject.new('test2')]
      row = row_subject.new
      cols.each { |c| row.add(c) }
      expect do
        subject.new.add(row)
      end.to_not raise_error Exception
    end

    context 'inherits' do
      before :each do
        @table = subject.new
        row = row_subject.new(color: 'red')
        (
          @cols1 = [
            col_subject.new('asdf', width: 5),
            col_subject.new('qwer', align: 'right', color: 'purple'),
            col_subject.new('tutu', color: 'green'),
            col_subject.new('uiui', bold: true)
          ]
        ).each { |c| row.add(c) }
        @table.add(row)
        row = row_subject.new
        (
          @cols2 = [
            col_subject.new('test'),
            col_subject.new('test'),
            col_subject.new('test', color: 'blue'),
            col_subject.new('test')
          ]
        ).each { |c| row.add(c) }
        @table.add(row)
      end

      context 'positional attributes' do
        it 'should inherit alignment' do
          4.times do |i|
            expect(@table.rows[1].columns[i].align).to eq(@table.rows[0].columns[i].align)
          end
        end

        it 'should inherit width' do
          4.times do |i|
            expect(@table.rows[1].columns[i].width).to eq(@table.rows[0].columns[i].width)
          end
        end

        it 'should inherit size' do
          4.times do |i|
            expect(@table.rows[1].columns[i].size).to eq(@table.rows[0].columns[i].size)
          end
        end

        it 'should inherit padding' do
          4.times do |i|
            expect(@table.rows[1].columns[i].padding).to eq(@table.rows[0].columns[i].padding)
          end
        end
      end

      context 'no header row' do
        it 'color' do
          expect(@table.rows[1].columns[0].color).to eq('red')
          expect(@table.rows[1].columns[1].color).to eq('purple')
          expect(@table.rows[1].columns[2].color).to eq('blue')
          expect(@table.rows[1].columns[3].color).to eq('red')
        end

        it 'bold' do
          expect(@table.rows[1].columns[0].bold).to be false
          expect(@table.rows[1].columns[1].bold).to be false
          expect(@table.rows[1].columns[2].bold).to be false
          expect(@table.rows[1].columns[3].bold).to be true
        end
      end

      context 'with header row' do
        before :each do
          @table = subject.new
          row = row_subject.new(header: true)
          @cols1.each { |c| row.add(c) }
          @table.add(row)
          row = row_subject.new
          @cols2.each { |c| row.add(c) }
          @table.add(row)
        end

        it 'color' do
          expect(@table.rows[1].columns[0].color).to eq('red')
          expect(@table.rows[1].columns[1].color).to eq('purple')
          expect(@table.rows[1].columns[2].color).to eq('blue')
          expect(@table.rows[1].columns[3].color).to eq('red')
        end

        it 'bold' do
          expect(@table.rows[1].columns[0].bold).to be false
          expect(@table.rows[1].columns[0].bold).to be false
          expect(@table.rows[1].columns[1].bold).to be false
          expect(@table.rows[1].columns[2].bold).to be false
          expect(@table.rows[1].columns[3].bold).to be true
        end
      end
    end
  end

  describe '#auto_adjust_widths' do
    it 'sets the widths of each column in each row to the maximum required width for that column' do
      table = subject.new.tap do |t|
        t.add(
          row_subject.new.tap do |r|
            r.add col_subject.new('medium length')
            r.add col_subject.new('i am pretty long') # longest column
            r.add col_subject.new('short', padding: 100)
          end
        )

        t.add(
          row_subject.new.tap do |r|
            r.add col_subject.new('longer than medium length') # longest column
            r.add col_subject.new('shorter')
            r.add col_subject.new('longer than short') # longest column (inherits padding)
          end
        )
      end

      table.auto_adjust_widths

      table.rows.each do |row|
        expect(row.columns[0].width).to eq(col_subject.new('longer than medium length').required_width)
        expect(row.columns[1].width).to eq(col_subject.new('i am pretty long').required_width)
        expect(row.columns[2].width).to eq(col_subject.new('longer than short', padding: 100).required_width)
      end
    end
  end
end
