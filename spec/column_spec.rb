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

    it 'accepts color' do
      Column.new('asdf', :color => 'red').color.should == 'red'
    end

    it 'accepts bold' do
      Column.new('asdf', :bold => true).bold.should == true
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
  end

  describe '#screen_rows' do
    before :all do
      @controls = {
        :clear => "\e[0m",
        :bold => "\e[1m",
        :red => "\e[31m",
      }
    end

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

        context 'left justifies' do
          before :each do
            @text = 'x' * 10
            @filler = ' ' * 10
          end

          it 'plain text' do
            c = Column.new(@text, :width => 20)
            c.screen_rows[0].should == @text + @filler
          end

          it 'outputs red' do
            c = Column.new(@text, :align => 'left', :width => 20, :color => 'red')
            c.screen_rows[0].should == @controls[:red] + @text + @filler + @controls[:clear]
          end

          it 'outputs bold' do
            c = Column.new(@text, :align => 'left', :width => 20, :bold => true)
            c.screen_rows[0].should == @controls[:bold] + @text + @filler + @controls[:clear]
          end
        end

        context 'right justifies' do
          before :each do
            @text = 'x' * 10
            @filler = ' ' * 10
          end

          it 'plain text' do
            c = Column.new(@text, :align => 'right', :width => 20)
            c.screen_rows[0].should == @filler + @text
          end

          it 'outputs red' do
            c = Column.new(@text, :align => 'right', :width => 20, :color => 'red')
            c.screen_rows[0].should == @controls[:red] + @filler + @text  + @controls[:clear]
          end

          it 'outputs bold' do
            c = Column.new(@text, :align => 'right', :width => 20, :bold => true)
            c.screen_rows[0].should == @controls[:bold] + @filler + @text + @controls[:clear]
          end
        end

        context 'center justifies' do
          before :each do
            @text = 'x' * 10
            @filler = ' ' * 5
          end

          it 'plain text' do
            c = Column.new(@text, :align => 'center', :width => 20)
            c.screen_rows[0].should == @filler + @text + @filler
          end

          it 'outputs red' do
            c = Column.new(@text, :align => 'center', :width => 20, :color => 'red')
            c.screen_rows[0].should == @controls[:red] + @filler + @text + @filler + @controls[:clear]
          end

          it 'outputs bold' do
            c = Column.new(@text, :align => 'center', :width => 20, :bold => true)
            c.screen_rows[0].should == @controls[:bold] + @filler + @text + @filler + @controls[:clear]
          end
        end
      end

      context 'accounts for padding' do
        context 'left justifies' do
          before :each do
            @text = 'x' * 10
            @padding = ' ' * 5
            @filler = ' ' * 10
          end

          it 'plain text' do
            c = Column.new(@text, :padding => 5, :width => 30)
            c.screen_rows[0].should == @padding + @text + @filler + @padding
          end

          it 'outputs red' do
            c = Column.new(@text, :padding => 5, :width => 30, :color => 'red')
            c.screen_rows[0].should == @padding + @controls[:red] + @text + @filler + @controls[:clear] + @padding
          end

          it 'outputs bold' do
            c = Column.new(@text, :padding => 5, :width => 30, :bold => true)
            c.screen_rows[0].should == @padding + @controls[:bold] + @text + @filler + @controls[:clear] + @padding
          end
        end

        context 'right justifies' do
          before :each do
            @text = 'x' * 10
            @padding = ' ' * 5
            @filler = ' ' * 10
          end

          it 'plain text' do
            c = Column.new(@text, :align => 'right', :padding => 5, :width => 30)
            c.screen_rows[0].should == @padding + @filler + @text + @padding
          end

          it 'outputs red' do
            c = Column.new(@text, :align => 'right', :padding => 5, :width => 30, :color => 'red')
            c.screen_rows[0].should == @padding + @controls[:red] + @filler + @text + @controls[:clear] + @padding
          end

          it 'outputs bold' do
            c = Column.new(@text, :align => 'right', :padding => 5, :width => 30, :bold => true)
            c.screen_rows[0].should == @padding + @controls[:bold] + @filler + @text + @controls[:clear] + @padding
          end
        end

        context 'right justifies' do
          before :each do
            @text = ' ' * 10
            @padding = ' ' * 5
            @filler = ' ' * 5
          end

          it 'plain text' do
            c = Column.new(@text, :align => 'center', :padding => 5, :width => 30)
            c.screen_rows[0].should == @padding + @filler + @text + @filler + @padding
          end

          it 'outputs red' do
            c = Column.new(@text, :align => 'center', :padding => 5, :width => 30, :color => 'red')
            c.screen_rows[0].should == @padding + @controls[:red] + @filler + @text + @filler + @controls[:clear] + @padding
          end

          it 'outputs bold' do
            c = Column.new(@text, :align => 'center', :padding => 5, :width => 30, :bold => true)
            c.screen_rows[0].should == @padding + @controls[:bold] + @filler + @text + @filler + @controls[:clear] + @padding
          end
        end
      end
    end

    context 'with wrapping' do
      context 'no padding' do
        context 'left justifies' do
          before :each do
            @text = 'x' * 25
            @full_line = 'x' * 10
            @remainder = 'x' * 5
            @filler = ' ' * 5
          end

          it 'plain text' do
            c = Column.new(@text, :width => 10)
            c.screen_rows.should == [@full_line, @full_line, @remainder + @filler]
          end

          it 'outputs red' do
            c = Column.new(@text, :width => 10, :color => 'red')
            c.screen_rows.should == [
              @controls[:red] + @full_line + @controls[:clear],
              @controls[:red] + @full_line + @controls[:clear],
              @controls[:red] + @remainder + @filler + @controls[:clear],
            ]
          end

          it 'outputs bold' do
            c = Column.new(@text, :width => 10, :bold => true)
            c.screen_rows.should == [
              @controls[:bold] + @full_line + @controls[:clear],
              @controls[:bold] + @full_line + @controls[:clear],
              @controls[:bold] + @remainder + @filler + @controls[:clear],
            ]
          end
        end

        context 'right justifies' do
          before :each do
            @text = 'x' * 25
            @full_line = 'x' * 10
            @remainder = 'x' * 5
            @filler = ' ' * 5
          end

          it 'plain text' do
            c = Column.new(@text, :align => 'right', :width => 10)
            c.screen_rows.should == [@full_line, @full_line, @filler + @remainder]
          end

          it 'outputs red' do
            c = Column.new(@text, :align => 'right', :width => 10, :color => 'red')
            c.screen_rows.should == [
              @controls[:red] + @full_line + @controls[:clear],
              @controls[:red] + @full_line + @controls[:clear],
              @controls[:red] + @filler + @remainder + @controls[:clear],
            ]
          end

          it 'outputs bold' do
            c = Column.new(@text, :align => 'right', :width => 10, :bold => true)
            c.screen_rows.should == [
              @controls[:bold] + @full_line + @controls[:clear],
              @controls[:bold] + @full_line + @controls[:clear],
              @controls[:bold] + @filler + @remainder + @controls[:clear],
            ]
          end
        end

        context 'center justifies' do
          before :each do
            @text = 'x' * 25
            @full_line = 'x' * 10
            @remainder = 'x' * 5
            @left_filler = ' ' * 3
            @right_filler = ' ' * 2
          end

          it 'plain text' do
            c = Column.new(@text, :align => 'center', :width => 10)
            c.screen_rows.should == [@full_line, @full_line, ' ' * 3 + @remainder + @right_filler]
          end

          it 'outputs red' do
            c = Column.new(@text, :align => 'center', :width => 10, :color => 'red')
            c.screen_rows.should == [
              @controls[:red] + @full_line + @controls[:clear],
              @controls[:red] + @full_line + @controls[:clear],
              @controls[:red] + @left_filler + @remainder + @right_filler + @controls[:clear],
            ]
          end

          it 'outputs bold' do
            c = Column.new(@text, :align => 'center', :width => 10, :bold => true)
            c.screen_rows.should == [
              @controls[:bold] + @full_line + @controls[:clear],
              @controls[:bold] + @full_line + @controls[:clear],
              @controls[:bold] + @left_filler + @remainder + @right_filler + @controls[:clear],
            ]
          end
        end
      end

      context 'account for padding' do
        context 'left justifies' do
          before :each do
            @text = 'x' * 25
            @full_line = 'x' * 16
            @remainder = 'x' * 9
            @padding = ' ' * 2
            @filler = ' ' * 7
          end

          it 'plain text' do
            c = Column.new(@text, :padding => 2, :width => 20)
            c.screen_rows.should == [
              @padding + @full_line + @padding,
              @padding + @remainder + @filler + @padding,
            ]
          end

          it 'outputs red' do
            c = Column.new(@text, :padding => 2, :width => 20, :color => 'red')
            c.screen_rows.should == [
              @padding + @controls[:red] + @full_line + @controls[:clear] + @padding,
              @padding + @controls[:red] + @remainder + @filler + @controls[:clear] + @padding,
            ]
          end

          it 'outputs bold' do
            c = Column.new(@text, :padding => 2, :width => 20, :bold => true)
            c.screen_rows.should == [
              @padding + @controls[:bold] + @full_line + @controls[:clear] + @padding,
              @padding + @controls[:bold] + @remainder + @filler + @controls[:clear] + @padding,
            ]
          end
        end

        context 'right justifies' do
          before :each do
            @text = 'x' * 25
            @full_line = 'x' * 16
            @remainder = 'x' * 9
            @padding = ' ' * 2
            @filler = ' ' * 7
          end

          it 'plain text' do
            c = Column.new(@text, :padding => 2, :align => 'right', :width => 20)
            c.screen_rows.should == [
              @padding + @full_line + @padding,
              @padding + @filler + @remainder + @padding,
            ]
          end

          it 'outputs red' do
            c = Column.new(@text, :align => 'right', :padding => 2, :width => 20, :color => 'red')
            c.screen_rows.should == [
              @padding + @controls[:red] + @full_line + @controls[:clear] + @padding,
              @padding + @controls[:red] + @filler + @remainder + @controls[:clear] + @padding,
            ]
          end

          it 'outputs bold' do
            c = Column.new(@text, :align => 'right', :padding => 2, :width => 20, :bold => true)
            c.screen_rows.should == [
              @padding + @controls[:bold] + @full_line + @controls[:clear] + @padding,
              @padding + @controls[:bold] + @filler + @remainder + @controls[:clear] + @padding,
            ]
          end
        end

        context 'center justifies' do
          before :each do
            @text = 'x' * 25
            @full_line = 'x' * 16
            @remainder = 'x' * 9
            @padding = ' ' * 2
            @left_filler = ' ' * 4
            @right_filler = ' ' * 3
          end

          it 'plain text' do
            c = Column.new(@text, :padding => 2, :align => 'center', :width => 20)
            c.screen_rows.should == [
              @padding + @full_line + @padding,
              @padding + @left_filler + @remainder + @right_filler + @padding,
            ]
          end

          it 'outputs red' do
            c = Column.new(@text, :padding => 2, :align => 'center', :width => 20, :color => 'red')
            c.screen_rows.should == [
              @padding + @controls[:red] + @full_line + @controls[:clear] + @padding,
              @padding + @controls[:red] + @left_filler + @remainder + @right_filler + @controls[:clear] + @padding,
            ]
          end

          it 'outputs bold' do
            c = Column.new(@text, :padding => 2, :align => 'center', :width => 20, :bold => true)
            c.screen_rows.should == [
              @padding + @controls[:bold] + @full_line + @controls[:clear] + @padding,
              @padding + @controls[:bold] + @left_filler + @remainder + @right_filler + @controls[:clear] + @padding,
            ]
          end
        end
      end
    end
  end
end
