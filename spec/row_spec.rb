require 'spec_helper'
require 'row'

describe CommandLineReporter::Row do
  let(:cols) { 10.times.map {|v| CommandLineReporter::Column.new("test#{v}")} }

  describe '#initialize' do
    it 'accepts header' do
      CommandLineReporter::Row.new(:header => true).header.should be_true
    end

    it 'accepts color' do
      CommandLineReporter::Row.new(:color => 'red').color.should == 'red'
    end

    it 'accepts bold' do
      CommandLineReporter::Row.new(:bold => true).bold.should be_true
    end
  end

  describe '#add' do
    subject { CommandLineReporter::Row.new }

    it 'columns' do
      subject.add(cols[0])
      subject.columns.size.should == 1
      subject.columns[0].should == cols[0]
      subject.add(cols[1])
      subject.columns.should == cols[0,2]
    end

    it 'defaults colors on columns' do
      row = CommandLineReporter::Row.new(:color => 'red')
      row.add(cols[0])
      row.columns[0].color.should == 'red'
      row.add(cols[1])
      row.columns[1].color.should == 'red'
    end

    it 'allows columns to override the row color' do
      col = CommandLineReporter::Column.new('test', :color => 'blue')
      row = CommandLineReporter::Row.new(:color => 'red')
      row.add(col)
      row.columns[0].color.should == 'blue'
    end

    it 'supercedes bold on columns' do
      row = CommandLineReporter::Row.new(:bold => true)
      row.add(cols[0])
      row.columns[0].bold.should be_true
      row.add(cols[1])
      row.columns[1].bold.should be_true
    end
  end

  describe '#output' do
    let :cols do
      [
        CommandLineReporter::Column.new('asdf'),
        CommandLineReporter::Column.new('qwer', :align => 'center'),
        CommandLineReporter::Column.new('zxcv', :align => 'right'),
        CommandLineReporter::Column.new('x' * 25, :align => 'left', :width => 10),
        CommandLineReporter::Column.new('x' * 25, :align => 'center', :width => 10),
        CommandLineReporter::Column.new('x' * 35, :align => 'left', :width => 10),
      ]
    end

    let(:one_space) { ' ' }
    let(:three_spaces) { ' {3,3}' }
    let(:six_spaces) { ' {6,6}' }
    let(:nine_spaces) { ' {9,9}' }
    let(:five_xs) { 'x{5,5}' }
    let(:ten_xs) { 'x{10,10}' }

    context 'no border' do
      context 'no wrap' do
        it 'outputs a single column' do
          subject.add(cols[0])
          subject.should_receive(:puts).with(/^asdf#{@six_pieces}/)
          subject.output
        end
        it 'outputs three columns' do
          subject.add(cols[0])
          subject.add(cols[1])
          subject.add(cols[2])
          subject.should_receive(:puts).with(/^asdf#{six_spaces}#{one_space}#{three_spaces}qwer#{three_spaces}#{one_space}#{six_spaces}zxcv $/)
          subject.output
        end
      end

      context 'with wrapping' do
        it 'outputs a single column' do
          subject.add(cols[3])
          subject.should_receive(:puts).with(/^#{ten_xs}#{one_space}$/)
          subject.should_receive(:puts).with(/^#{ten_xs}#{one_space}$/)
          subject.should_receive(:puts).with(/^#{five_xs}#{six_spaces}$/)
          subject.output
        end

        it 'outputs multiple columns of the same size' do
          subject.add(cols[3])
          subject.add(cols[4])
          subject.should_receive(:puts).with(/^#{ten_xs}#{one_space}#{ten_xs}#{one_space}$/)
          subject.should_receive(:puts).with(/^#{ten_xs}#{one_space}#{ten_xs}#{one_space}$/)
          subject.should_receive(:puts).with(/^#{five_xs}#{nine_spaces}#{five_xs}#{three_spaces}$/)
          subject.output
        end

        it 'outputs multiple columns with different sizes' do
          subject.add(cols[5])
          subject.add(cols[3])
          subject.should_receive(:puts).with(/^#{ten_xs}#{one_space}#{ten_xs}#{one_space}$/)
          subject.should_receive(:puts).with(/^#{ten_xs}#{one_space}#{ten_xs}#{one_space}$/)
          subject.should_receive(:puts).with(/^#{ten_xs}#{one_space}#{five_xs}#{six_spaces}$/)
          subject.should_receive(:puts).with(/^#{five_xs} {5,17}$/)
          subject.output
        end
      end
    end
  end
end
