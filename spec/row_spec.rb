require 'spec_helper'
require 'row'

describe Row do
  before :each do
    @cols = 10.times.map {|v| Column.new("test#{v}")}
  end

  context 'Creation' do
    it 'in the absence of columns' do
      expect {
        Row.new
      }.to_not raise_error
    end

    it 'accepts array of columns' do
      expect {
        Row.new(@cols)
      }.to_not raise_error
    end
  end

  context 'collection management' do
    subject { Row.new }

    it 'adds column to an empty row' do
      subject.add(@cols[0])
      subject.columns.size.should == 1
      subject.columns[0].should == @cols[0]
    end

    it 'adds column to the end of row' do
      row = Row.new(@cols)
      coln = Column.new('test3')
      row.add(coln)
      row.columns.should == @cols << coln
    end
  end
end
