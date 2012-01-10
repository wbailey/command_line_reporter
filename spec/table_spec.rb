require 'spec_helper'
require 'table'

describe Table do
  context 'creation' do
    it 'defaults options hash' do
      expect {
        Table.new
      }.to_not raise_error
    end

    it 'defaults the width' do
      Table.new.width.should == 100
    end

    it 'accepts the width' do
      Table.new(:width => 50).width.should == 50
    end

    it 'requires valid widths' do
      expect {
        Table.new(:width => 'asdf')
      }.to raise_error ArgumentError
    end

    it 'defaults the border' do
      Table.new.border.should == false
    end

    it 'accepts the border' do
      Table.new(:border => true).border.should == true
    end

    it 'defaults the padding' do
      Table.new.padding.should == 1
    end

    it 'accepts the padding' do
      Table.new(:padding => 10).padding.should == 10
    end

    it 'requires valid padding' do
      expect {
        Table.new(:padding => 'asdf')
      }.to raise_error ArgumentError
    end
  end

  context 'rows' do
    it 'allows addition' do
      cols = [Column.new('test1'), Column.new('test2')]
      row = Row.new
      cols.each {|c| row.add(c)}
      Table.new.add_row(row)
    end
  end

  context 'prints to screen' do
    context 'no wrapping' do
      before :each do
        @rows = [Row.new, Row.new]
        @rows[0].add Column.new('asdf')
        @rows[0].add Column.new('qwer', :align => 'center')
        @rows[0].add Column.new('zxcv', :align => 'right')
        @rows[1].add Column.new('yuip')
        @rows[1].add Column.new('hjkl', :align => 'center')
        @rows[1].add Column.new('bnmm', :align => 'right')
        @six_spaces = ' {6,6}'
        @three_spaces = ' {3,3}'
      end

      it 'having a single column' do
        c = Column.new('asdf')
        r = Row.new
        t = Table.new
        t.should_receive(:puts).with(/^asdf#{@six_spaces} $/)
        r.add(c)
        t.add_row(r)
        t.to_s
      end

      it 'having a single row and three columns' do
        t = Table.new
        t.add_row(@rows[0])
        t.should_receive(:puts).with(/^asdf#{@six_spaces} #{@three_spaces}qwer#{@three_spaces} #{@six_spaces}zxcv $/)
        t.to_s
      end

      it 'having multiple rows and three columns' do
        t = Table.new
        t.should_receive(:puts).with(/^asdf#{@six_spaces} #{@three_spaces}qwer#{@three_spaces} #{@six_spaces}zxcv $/)
        t.should_receive(:puts).with(/^yuip#{@six_spaces} #{@three_spaces}hjkl#{@three_spaces} #{@six_spaces}bnmm $/)
        t.add_row(@rows[0])
        t.add_row(@rows[1])
        t.to_s
      end
    end

    context 'with wrapping' do
      before :each do
        @rows = [Row.new, Row.new]
        @rows[0].add Column.new('x' * 25, :align => 'left', :width => 10)
        @rows[0].add Column.new('qwer', :align => 'center')
        @rows[0].add Column.new('zxcv', :align => 'right')
        @rows[1].add Column.new('yuip')
        @rows[1].add Column.new('hjkl', :align => 'center')
        @rows[1].add Column.new('bnmm', :align => 'right')
      end

      # it 'having a single column' do
      #   c = Column.new('x' * 25, :align => 'left', :width => 10)
      #   r = Row.new
      #   t = Table.new
      #   t.should_receive(:puts).with(/x{10,10}/, /x{10,10}/, /x{5,5}/)
      #   r.add(c)
      #   t.add_row(r)
      #   t.to_s
      # end
    end
  end
end
