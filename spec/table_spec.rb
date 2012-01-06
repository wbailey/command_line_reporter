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

  context 'prints' do
    before :each do
      @rows = [Row.new, Row.new]
      @rows[0].add Column.new('asdf')
      @rows[0].add Column.new('qwer')
      @rows[0].add Column.new('zxcv')
      @rows[1].add Column.new('yuip')
      @rows[1].add Column.new('hjkl')
      @rows[1].add Column.new('bnmm')
    end

    it 'a basic unformatted table' do
      subject = Table.new

      subject.should_receive(:print).with(/^asdf/).once
      subject.should_receive(:print).with(/^qwer/).once
      subject.should_receive(:print).with(/^zxcv/).once
      subject.should_receive(:print).with(/^yuip/).once
      subject.should_receive(:print).with(/^hjkl/).once
      subject.should_receive(:print).with(/^bnmm/).once
      subject.should_receive(:puts).twice

      subject.add_row(@rows[0])
      subject.add_row(@rows[1])

      subject.to_s
    end

    it 'a basic table with border' do
      subject = Table.new(:border => true)
      seperator = '-' * 100

      subject.should_receive(:puts).with(/^-{100}/).once
      subject.should_receive(:print).any_number_of_times
      subject.should_receive(:puts)

      subject.add_row(@rows[0])

      subject.to_s
    end
  end
end
