require 'spec_helper'

describe CommandLineReporter::Table do
  context 'creation' do
    it 'defaults options hash' do
      expect {
        CommandLineReporter::Table.new
      }.to_not raise_error
    end

    it 'defaults the border' do
      expect(CommandLineReporter::Table.new.border).to be_false
    end

    it 'accepts the border' do
      expect(CommandLineReporter::Table.new(:border => true).border).to eq(true)
    end

    it 'output encoding should be ascii' do
      expect(CommandLineReporter::Table.new(:encoding => :ascii).encoding).to eq(:ascii)
    end

    it 'output encoding should be unicode' do
      expect(CommandLineReporter::Table.new.encoding).to eq(:unicode)
    end
  end

  context 'rows' do
    it 'allows addition' do
      cols = [CommandLineReporter::Column.new('test1'), CommandLineReporter::Column.new('test2')]
      row = CommandLineReporter::Row.new
      cols.each {|c| row.add(c)}
      expect {
        CommandLineReporter::Table.new.add(row)
      }.to_not raise_error
    end

    context 'inherits' do
      before :each do
        @table = CommandLineReporter::Table.new
        row = CommandLineReporter::Row.new(:color => 'red')
        (
          @cols1 = [
            CommandLineReporter::Column.new('asdf', :width => 5),
            CommandLineReporter::Column.new('qwer', :align => 'right', :color => 'purple'),
            CommandLineReporter::Column.new('tutu', :color => 'green'),
            CommandLineReporter::Column.new('uiui', :bold => true),
          ]
        ).each {|c| row.add(c)}
        @table.add(row)
        row = CommandLineReporter::Row.new
        (@cols2 = [
            CommandLineReporter::Column.new('test'),
            CommandLineReporter::Column.new('test'),
            CommandLineReporter::Column.new('test', :color => 'blue'),
            CommandLineReporter::Column.new('test'),
          ]
        ).each {|c| row.add(c)}
        @table.add(row)
      end

      it 'positional attributes' do
        [:align, :width, :size, :padding].each do |m|
          4.times do |i|
            expect(@table.rows[1].columns[i].send(m)).to eq(@table.rows[0].columns[i].send(m))
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
          expect(@table.rows[1].columns[0].bold).to be_false
          expect(@table.rows[1].columns[1].bold).to be_false
          expect(@table.rows[1].columns[2].bold).to be_false
          expect(@table.rows[1].columns[3].bold).to be_true
        end
      end

      context 'with header row' do
        before :each do
          @table = CommandLineReporter::Table.new
          row = CommandLineReporter::Row.new(:header => true)
          @cols1.each {|c| row.add(c)}
          @table.add(row)
          row = CommandLineReporter::Row.new
          @cols2.each {|c| row.add(c)}
          @table.add(row)
        end

        it 'bold' do
          expect(@table.rows[1].columns[0].bold).to be_false
          expect(@table.rows[1].columns[1].bold).to be_false
          expect(@table.rows[1].columns[2].bold).to be_false
          expect(@table.rows[1].columns[3].bold).to be_true
        end
      end
    end
  end

  describe '#auto_adjust_widths' do
    it 'sets the widths of each column in each row to the maximum required width for that column' do
      table = CommandLineReporter::Table.new.tap do |t|
        t.add(
          CommandLineReporter::Row.new.tap do |r|
            r.add CommandLineReporter::Column.new('medium length')
            r.add CommandLineReporter::Column.new('i am pretty long') # longest column
            r.add CommandLineReporter::Column.new('short', :padding => 100)
          end
        )

        t.add(
          CommandLineReporter::Row.new.tap do |r|
            r.add CommandLineReporter::Column.new('longer than medium length') # longest column
            r.add CommandLineReporter::Column.new('shorter')
            r.add CommandLineReporter::Column.new('longer than short') # longest column (inherits padding)
          end
        )
      end

      table.auto_adjust_widths

      table.rows.each do |row|
        expect(row.columns[0].width).to eq(CommandLineReporter::Column.new('longer than medium length').required_width)
        expect(row.columns[1].width).to eq(CommandLineReporter::Column.new('i am pretty long').required_width)
        expect(row.columns[2].width).to eq(CommandLineReporter::Column.new('longer than short', :padding => 100).required_width)
      end
    end
  end

end
