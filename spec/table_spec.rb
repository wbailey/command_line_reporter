require 'spec_helper'
require 'table'

describe Table do
  context 'creation' do
    it 'defaults options hash' do
      expect {
        Table.new
      }.to_not raise_error
    end

    it 'defaults the border' do
      Table.new.border.should == false
    end

    it 'accepts the border' do
      Table.new(:border => true).border.should == true
    end
  end

  context 'rows' do
    it 'allows addition' do
      cols = [Column.new('test1'), Column.new('test2')]
      row = Row.new
      cols.each {|c| row.add(c)}
      Table.new.add(row)
    end
  end
end
