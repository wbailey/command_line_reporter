require 'spec_helper'
require 'row'

describe Row do
  before :each do
    @cols = 10.times.map {|v| Column.new("test#{v}")}
  end

  context 'collection management' do
    subject { Row.new }

    it 'effectively adds column to a row' do
      subject.add(@cols[0])
      subject.columns.size.should == 1
      subject.columns[0].should == @cols[0]
      subject.add(@cols[1])
      subject.columns.should == @cols[0,2]
    end
  end
end
