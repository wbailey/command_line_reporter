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
      row = Row.new(cols)
      Table.new.add_row(row)
    end
  end
end
