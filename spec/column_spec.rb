require 'spec_helper'
require 'column'

describe Column do
  context 'creation' do
    it 'defaults options hash' do
      expect {
        Column.new('test')
      }.to_not raise_error
    end

    it 'defaults the width' do
      Column.new('test').width.should == 10
    end

    it 'accepts the width' do
      Column.new('test', :width => 50).width.should == 50
    end

    it 'requires valid width' do
      expect {
        Column.new('test', :width => 'asdf')
      }.to raise_error ArgumentError
    end

    it 'accepts text' do
      Column.new('asdf').text.should == 'asdf'
    end

    it 'defaults the padding' do
      Column.new('test').padding.should == 1
    end

    it 'accepts the padding' do
      Column.new('test', :padding => 5).padding.should == 5
    end

    it 'requires valid width' do
      expect {
        Column.new('test', :padding => 'asdf')
      }.to raise_error ArgumentError
    end

    it 'is immutable' do
      c = Column.new('test')

      expect {
        c.text = 'asdf'
      }.to raise_error RuntimeError, /frozen object/

      expect {
        c.width = 123
      }.to raise_error RuntimeError, /frozen object/

      expect {
        c.padding = 123
      }.to raise_error RuntimeError, /frozen object/
    end
  end

  context 'manages chunks' do
    subject { Column.new('asdf asdfasdf qwerqwer qwer', {:border => '|'}) }

    before :each do
      @result = ['asdf asd', 'fasdf qw', 'erqwer q', 'wer']
    end

    it 'applies left border with padding' do
      subject.screen_rows.should  == @result.map {|r| "| #{r.ljust(8)} |"}
    end
  end
end
