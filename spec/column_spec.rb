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

    it 'defaults the padding' do
      Column.new('test').padding.should == 0
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

    context 'with wrapping' do
      context 'no padding' do
        it 'left justifies' do
          c = Column.new('x' * 25, :width => 10)
          c.screen_rows.should == ['x' * 10, 'x' * 10, 'x' * 5 + ' ' * 5]
        end

        it 'left justifies' do
          c = Column.new('x' * 25, :align => 'right', :width => 10)
          c.screen_rows.should == ['x' * 10, 'x' * 10, ' ' * 5 + 'x' * 5]
        end

        it 'left justifies' do
          c = Column.new('x' * 25, :align => 'center', :width => 10)
          c.screen_rows.should == ['x' * 10, 'x' * 10, ' ' * 3 + 'x' * 5 + ' ' * 2]
        end
      end

      context 'account for padding' do
        it 'left justifies' do
          c = Column.new('x' * 25, :padding => 2, :width => 20)
          c.screen_rows.should == [' ' * 2 + 'x' * 16 + ' ' * 2, ' ' * 2 + 'x' * 9 + ' ' * 9]
        end

        it 'right justifies' do
          c = Column.new('x' * 25, :padding => 2, :align => 'right', :width => 20)
          c.screen_rows.should == [' ' * 2 + 'x' * 16 + ' ' * 2, ' ' * 9 + 'x' * 9 + ' ' * 2]
        end

        it 'center justifies' do
          c = Column.new('x' * 25, :padding => 2, :align => 'center', :width => 20)
          c.screen_rows.should == [' ' * 2 + 'x' * 16 + ' ' * 2,  ' ' * 6 + 'x' * 9 + ' ' * 5]
        end
      end
    end
  end
end
