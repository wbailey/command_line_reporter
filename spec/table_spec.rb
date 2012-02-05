require 'spec_helper'
require 'table'

describe CommandLineReporter::Table do
  context 'creation' do
    it 'defaults options hash' do
      expect {
        CommandLineReporter::Table.new
      }.to_not raise_error
    end

    it 'defaults the border' do
      CommandLineReporter::Table.new.border.should be_false
    end

    it 'accepts the border' do
      CommandLineReporter::Table.new(:border => true).border.should == true
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
            @table.rows[1].columns[i].send(m).should == @table.rows[0].columns[i].send(m)
          end
        end
      end

      context 'no header row' do
        it 'color' do
          @table.rows[1].columns[0].color.should == 'red'
          @table.rows[1].columns[1].color.should == 'purple'
          @table.rows[1].columns[2].color.should == 'blue'
          @table.rows[1].columns[3].color.should == 'red'
        end

        it 'bold' do
          @table.rows[1].columns[0].bold.should be_false
          @table.rows[1].columns[1].bold.should be_false
          @table.rows[1].columns[2].bold.should be_false
          @table.rows[1].columns[3].bold.should be_true
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
          @table.rows[1].columns[0].bold.should be_false
          @table.rows[1].columns[1].bold.should be_false
          @table.rows[1].columns[2].bold.should be_false
          @table.rows[1].columns[3].bold.should be_true
        end
      end
    end
  end
end
