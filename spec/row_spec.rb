require 'spec_helper'
require 'row'

describe Row do
  before :each do
    @cols = 10.times.map {|v| Column.new("test#{v}")}
  end

  describe '#initialize' do
    it 'accepts header' do
      Row.new(:header => true).header.should == true
    end

    it 'accepts color' do
      Row.new(:color => 'red').color.should == 'red'
    end

    it 'accepts bold' do
      Row.new(:bold => true).bold.should == true
    end
  end

  describe '#add' do
    subject { Row.new }

    it 'adds columns' do
      subject.add(@cols[0])
      subject.columns.size.should == 1
      subject.columns[0].should == @cols[0]
      subject.add(@cols[1])
      subject.columns.should == @cols[0,2]
    end

    it 'defaults colors on columns' do
      row = Row.new(:color => 'red')
      row.add(@cols[0])
      row.columns[0].color.should == 'red'
      row.add(@cols[1])
      row.columns[1].color.should == 'red'
    end

    it 'defaults bold on columns' do
      row = Row.new(:bold => true)
      row.add(@cols[0])
      row.columns[0].bold.should == true
      row.add(@cols[1])
      row.columns[1].bold.should == true
    end
  end

  describe '#output' do
    before :each do
      @cols = [
        Column.new('asdf'),
        Column.new('qwer', :align => 'center'),
        Column.new('zxcv', :align => 'right'),
        Column.new('x' * 25, :align => 'left', :width => 10),
        Column.new('x' * 25, :align => 'center', :width => 10),
        Column.new('x' * 35, :align => 'left', :width => 10),
      ]
    end

    before :all do
      @one_space = ' '
      @three_spaces = ' {3,3}'
      @six_spaces = ' {6,6}'
      @nine_spaces = ' {9,9}'
      @five_xs = 'x{5,5}'
      @ten_xs = 'x{10,10}'
    end

    context 'no border' do
      context 'no wrap' do
        it 'outputs a single column' do
          subject.add(@cols[0])
          subject.should_receive(:puts).with(/^asdf#{@six_pieces}/)
          subject.output
        end
        it 'outputs three columns' do
          subject.add(@cols[0])
          subject.add(@cols[1])
          subject.add(@cols[2])
          subject.should_receive(:puts).with(/^asdf#{@six_spaces}#{@one_space}#{@three_spaces}qwer#{@three_spaces}#{@one_space}#{@six_spaces}zxcv $/)
          subject.output
        end
      end

      context 'with wrapping' do
        it 'outputs a single column' do
          subject.add(@cols[3])
          subject.should_receive(:puts).with(/^#{@ten_xs}#{@one_space}$/)
          subject.should_receive(:puts).with(/^#{@ten_xs}#{@one_space}$/)
          subject.should_receive(:puts).with(/^#{@five_xs}#{@six_spaces}$/)
          subject.output
        end

        it 'outputs multiple columns of the same size' do
          subject.add(@cols[3])
          subject.add(@cols[4])
          subject.should_receive(:puts).with(/^#{@ten_xs}#{@one_space}#{@ten_xs}#{@one_space}$/)
          subject.should_receive(:puts).with(/^#{@ten_xs}#{@one_space}#{@ten_xs}#{@one_space}$/)
          subject.should_receive(:puts).with(/^#{@five_xs}#{@nine_spaces}#{@five_xs}#{@three_spaces}$/)
          subject.output
        end

        it 'outputs multiple columns with different sizes' do
          subject.add(@cols[5])
          subject.add(@cols[3])
          subject.should_receive(:puts).with(/^#{@ten_xs}#{@one_space}#{@ten_xs}#{@one_space}$/)
          subject.should_receive(:puts).with(/^#{@ten_xs}#{@one_space}#{@ten_xs}#{@one_space}$/)
          subject.should_receive(:puts).with(/^#{@ten_xs}#{@one_space}#{@five_xs}#{@six_spaces}$/)
          subject.should_receive(:puts).with(/^#{@five_xs} {5,17}$/)
          subject.output
        end
      end
    end
  end
end
