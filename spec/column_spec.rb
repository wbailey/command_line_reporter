require 'spec_helper'
require 'column'

describe Column do
  context 'creation' do
    it 'rejects invalid options' do
      expect {
        Column.new('test', :asdf => '1234')
      }.to raise_error ArgumentError
    end

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

    context 'defaults the padding' do
      it 'without border' do
        Column.new('test').padding.should == 0
      end

      it 'with border' do
        Column.new('test', :border => true).padding.should == 1
      end
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

  describe '#screen_rows' do
    context 'no wrapping' do
      context 'no padding' do
        it 'gives a single row' do
          c = Column.new('x' * 5)
          c.screen_rows.size == 1
        end

        it 'handles empty text' do
          c = Column.new
          c.screen_rows[0].should == ' ' * 10
        end

        it 'left justifies' do
          c = Column.new('x' * 10, :width => 20)
          c.screen_rows[0].should == 'x' * 10 + ' ' * 10
        end

        it 'right justifies' do
          c = Column.new('x' * 10, :align => 'right', :width => 20)
          c.screen_rows[0].should == ' ' * 10 + 'x' * 10
        end

        it 'center justifies' do
          c = Column.new('x' * 10, :align => 'center', :width => 20)
          c.screen_rows[0].should == ' ' * 5 + 'x' * 10 + ' ' * 5
        end
      end

      context 'accounts for padding' do
        it 'left justifies' do
          c = Column.new('x' * 10, :padding => 5, :width => 30)
          c.screen_rows[0].should == ' ' * 5 + 'x' * 10 + ' ' * 15
        end
        it 'right justifies' do
          c = Column.new('x' * 10, :align => 'right', :padding => 5, :width => 30)
          c.screen_rows[0].should == ' ' * 15 + 'x' * 10 + ' ' * 5
        end
        it 'right justifies' do
          c = Column.new('x' * 10, :align => 'center', :padding => 5, :width => 30)
          c.screen_rows[0].should == ' ' * 10 + 'x' * 10 + ' ' * 10
        end
      end
    end
  end
end
