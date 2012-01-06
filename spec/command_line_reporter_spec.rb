require 'spec_helper'
require 'command_line_reporter'

describe CommandLineReporter do
  let :use_class do
    Class.new do
      include CommandLineReporter
    end
  end

  subject { use_class.new }

  before :each do
    @timestamp_regex = /\d{4}-\d{2}-\d{2} - (\d| )\d:\d{2}:\d{2}[AP]M/
  end

  describe '#formatter=' do
    it 'only allows allowed formatters' do
      expect {
        subject.formatter = 'asfd'
      }.to raise_error ArgumentError
    end

    it 'specifies the progress formatter' do
      subject.formatter = 'progress'
      subject.formatter.class.should == CommandLineReporter::ProgressFormatter
    end

    it 'specifies the nested formatter' do
      subject.formatter = 'nested'
      subject.formatter.class.should == CommandLineReporter::NestedFormatter
    end
  end

  describe '#report' do
    it 'uses the nested formatter as default' do
      capture_stdout {
        subject.report { }
      }

      subject.formatter.class.should == CommandLineReporter::NestedFormatter
    end

    it 'uses the progress formatter' do
      capture_stdout {
        subject.formatter = 'progress'
        subject.report { }
      }

      subject.formatter.class.should == CommandLineReporter::ProgressFormatter
    end

    it 'does not mask other application errors when a formatter is not set' do
      capture_stdout {
        subject.report {
          lambda {self.some_method_that_does_not_exist}.should raise_error(NoMethodError)
        }
      }
    end
  end

  describe '#header' do
    context 'argument validation' do

      it 'does not accept an invalid option' do
        expect {
          subject.header(:asdf => 'tests')
        }.to raise_error ArgumentError
      end

      it 'accepts a title' do
        expect {
          subject.should_receive(:puts).any_number_of_times
          subject.header(:title => 'test')
        }.to_not raise_error ArgumentError
      end

      it 'does not allow a title > width' do
        expect {
          subject.header(:title => 'xxxxxxxxxxx', :width => 5)
        }.to raise_error ArgumentError
      end

      it 'accepts width' do
        expect {
          subject.should_receive(:puts).any_number_of_times
          subject.header(:width => 100)
        }.to_not raise_error ArgumentError
      end

      it 'ensure width is a number' do
        expect {
          subject.header(:width => '100')
        }.to raise_error ArgumentError
      end

      it 'accepts align' do
        expect {
          subject.should_receive(:puts).any_number_of_times
          subject.header(:align => 'center')
        }.to_not raise_error ArgumentError
      end

      it 'ensure align is a valid value' do
        expect {
          subject.header(:align => :asdf)
        }.to raise_error ArgumentError
      end

      it 'accepts spacing' do
        expect {
          subject.should_receive(:puts).any_number_of_times
          subject.header(:spacing => 2)
        }.to_not raise_error ArgumentError
      end

      it 'accepts timestamp' do
        expect {
          subject.should_receive(:puts).any_number_of_times
          subject.header(:timestamp => true)
        }.to_not raise_error ArgumentError
      end
    end

    context 'alignment' do
      before :each do
        @title = 'test11test'
      end

      it 'left aligns title by default' do
        subject.should_receive(:puts).with(@title)
        subject.should_receive(:puts).with("\n")
        subject.header(:title => @title) { }
      end

      it 'left aligns title' do
        subject.should_receive(:puts).with(@title)
        subject.should_receive(:puts).with("\n")
        subject.header(:title => @title, :align => 'left') { }
      end

      it 'right aligns title using default width' do
        subject.should_receive(:puts).with(' ' * 90 + @title)
        subject.should_receive(:puts).with("\n")
        subject.header(:title => @title, :align => 'right')
      end

      it 'right aligns title using specified width' do
        subject.should_receive(:puts).with(' ' * 40 + @title)
        subject.should_receive(:puts).with("\n")
        subject.header(:title => @title, :align => 'right', :width => 50)
      end

      it 'center aligns title using default width' do
        subject.should_receive(:puts).with(' ' * 45 + @title)
        subject.should_receive(:puts).with("\n")
        subject.header(:title => @title, :align => 'center')
      end

      it 'center aligns title using specified width' do
        subject.should_receive(:puts).with(' ' * 35 + @title)
        subject.should_receive(:puts).with("\n")
        subject.header(:title => @title, :align => 'center', :width => 80)
      end
    end

    context 'spacing' do
      it 'defaults to a single line of spacing between report' do
        subject.should_receive(:puts).with('title')
        subject.should_receive(:puts).with("\n")
        subject.header(:title => 'title')
      end

      it 'uses the defined spacing between report' do
        subject.should_receive(:puts).with('title')
        subject.should_receive(:puts).with("\n" * 3)
        subject.header(:title => 'title', :spacing => 3)
      end
    end

    context 'timestamp subheading' do
      it 'is added with default alignment' do
        subject.should_receive(:puts).with('title')
        subject.should_receive(:puts).with(/^#{@timestamp_regex}/)
        subject.should_receive(:puts).with("\n")
        subject.header(:title => 'title', :timestamp => true)
      end

      it 'added with right alignment' do
        subject.should_receive(:puts).with(/^ *title$/)
        subject.should_receive(:puts).with(/^ *#{@timestamp_regex}$/)
        subject.should_receive(:puts).with("\n")
        subject.header(:title => 'title', :align => 'right', :timestamp => true, :width => 80)
      end

      it 'added with center alignment' do
        subject.should_receive(:puts).with(/^ *title *$/)
        subject.should_receive(:puts).with(/^ *#{@timestamp_regex} *$/)
        subject.should_receive(:puts).with("\n")
        subject.header(:title => 'title', :align => 'center', :timestamp => true, :width => 80)
      end
    end

    context 'horizontal rule' do
      it 'uses dashes by default' do
        subject.should_receive(:puts)
        subject.should_receive(:puts).with('-' * 100)
        subject.should_receive(:puts)
        subject.header(:rule => true)
      end

      it 'uses = as the rule character' do
        subject.should_receive(:puts)
        subject.should_receive(:puts).with('=' * 100)
        subject.should_receive(:puts)
        subject.header(:rule => '=')
      end
    end
  end

  describe '#horizontal_rule' do
    context 'argument validation' do
      it 'does not allow invalid options' do
        expect {
          subject.horizontal_rule(:asdf => true)
        }.to raise_error ArgumentError
      end

      it 'accepts char' do
        expect {
          subject.should_receive(:puts)
          subject.horizontal_rule(:char => '*')
        }.to_not raise_error ArgumentError
      end

      it 'accepts width' do
        expect {
          subject.should_receive(:puts)
          subject.horizontal_rule(:width => 10)
        }.to_not raise_error ArgumentError
      end
    end

    context 'drawing' do
      it 'writes a 100 yard dash by default' do
        subject.should_receive(:puts).with('-' * 100)
        subject.horizontal_rule
      end

      it 'writes a 100 yard asterisk' do
        subject.should_receive(:puts).with('*' * 100)
        subject.horizontal_rule(:char => '*')
      end

      it 'writes a 50 yard equals' do
        subject.should_receive(:puts).with('=' * 50)
        subject.horizontal_rule(:char => '=', :width => 50)
      end
    end
  end

  describe '#vertical_spacing' do
    it 'accepts a fixnum as a valid argument' do
      expect {
        subject.vertical_spacing('asdf')
      }.to raise_error ArgumentError
    end

    it 'prints carriage returns for the number of lines' do
      subject.should_receive(:puts).with("\n" * 3)
      subject.vertical_spacing(3)
    end
  end

  describe '#datetime' do
    context 'argument validation' do
      it 'does not allow invalid options' do
        expect {
          subject.datetime(:asdf => true)
        }.to raise_error ArgumentError
      end

      it 'accepts align' do
        expect {
          subject.should_receive(:puts)
          subject.datetime(:align => 'left')
        }.to_not raise_error ArgumentError
      end

      it 'accepts width' do
        expect {
          subject.should_receive(:puts)
          subject.datetime(:width => 70)
        }.to_not raise_error ArgumentError
      end

      it 'accepts format' do
        expect {
          subject.should_receive(:puts)
          subject.datetime(:format => '%m/%d/%Y')
        }.to_not raise_error ArgumentError
      end

      it 'does not allow invalid width' do
        expect {
          subject.datetime(:align => 'right', :width => 'asdf')
        }.to raise_error
      end

      it 'does not allow invalid align' do
        expect {
          subject.datetime(:align => 1234)
        }.to raise_error
      end

      it 'does not allow a timestamp format larger than the width' do
        expect {
          subject.datetime(:width => 8)
        }.to raise_error
      end
    end

    context 'display' do
      it 'a default format - left aligned' do
        subject.should_receive(:puts).with(/^#{@timestamp_regex} *$/)
        subject.datetime
      end

      it 'a default format - right aligned' do
        subject.should_receive(:puts).with(/^ *#{@timestamp_regex}$/)
        subject.datetime(:align => 'right')
      end

      it 'a default format - center aligned' do
        subject.should_receive(:puts).with(/^ *#{@timestamp_regex} *$/)
        subject.datetime(:align => 'center')
      end

      it 'a modified format' do
        subject.should_receive(:puts).with(/^\d{2}\/\d{2}\/\d{2} *$/)
        subject.datetime(:format => '%y/%m/%d')
      end
    end
  end

  describe '#aligned' do
    context 'argument validation' do
      it 'accepts align' do
        expect {
          subject.should_receive(:puts).any_number_of_times
          subject.aligned('test', :align => 'left')
        }.to_not raise_error
      end

      it 'does not allow invalid align values' do
        expect {
          subject.aligned('test', :align => 1234)
        }.to raise_error ArgumentError
      end

      it 'accepts width' do
        expect {
          subject.should_receive(:puts).any_number_of_times
          subject.aligned('test', :width => 40)
        }.to_not raise_error
      end

      it 'does not allow invalid width values' do
        expect {
          subject.aligned('test', :align => 'right', :width => 'asdf')
        }.to raise_error
      end
    end
  end

  describe '#footer' do
    context 'argument validation' do
      it 'accepts title' do
        expect {
          subject.should_receive(:puts).any_number_of_times
          subject.footer(:title => 'test')
        }.to_not raise_error
      end

      it 'accepts align' do
        expect {
          subject.should_receive(:puts).any_number_of_times
          subject.footer(:align => 'right')
        }.to_not raise_error ArgumentError
      end

      it 'does not accept invalid align' do
        expect {
          subject.header(:align => 1234)
        }.to raise_error ArgumentError
      end

      it 'accepts width' do
        expect {
          subject.should_receive(:puts).any_number_of_times
          subject.footer(:width => 50)
        }.to_not raise_error
      end

      it 'does not accept invalid width' do
        expect {
          subject.footer(:width => 'asdf')
        }.to raise_error ArgumentError
      end

      it 'does not allow title > width' do
        expect {
          subject.footer(:title => 'testtesttest', :width => 6)
        }.to raise_error ArgumentError
      end

      it 'accepts spacing' do
        expect {
          subject.should_receive(:puts).any_number_of_times
          subject.footer(:spacing => 3)
        }.to_not raise_error
      end
    end

    context 'alignment' do
      before :each do
        @title = 'test12test'
      end

      it 'left aligns the title by default' do
        subject.should_receive(:puts).with("\n")
        subject.should_receive(:puts).with(@title)
        subject.footer(:title => @title)
      end

      it 'left aligns the title' do
        subject.should_receive(:puts).with("\n")
        subject.should_receive(:puts).with(@title)
        subject.footer(:title => @title, :align => 'left')
      end

      it 'right aligns the title' do
        subject.should_receive(:puts).with("\n")
        subject.should_receive(:puts).with(' ' * 90 + @title)
        subject.footer(:title => @title, :align => 'right')
      end

      it 'right aligns the title using width' do
        subject.should_receive(:puts).with("\n")
        subject.should_receive(:puts).with(' ' * 40 + @title)
        subject.footer(:title => @title, :align => 'right', :width => 50)
      end

      it 'center aligns the title' do
        subject.should_receive(:puts).with("\n")
        subject.should_receive(:puts).with(' ' * 45 + @title)
        subject.footer(:title => @title, :align => 'center')
      end

      it 'center aligns the title using width' do
        subject.should_receive(:puts).with("\n")
        subject.should_receive(:puts).with(' ' * 35 + @title)
        subject.footer(:title => @title, :align => 'center', :width => 80)
      end
    end

    context 'spacing' do
      it 'defaults to a single line of spacing between report' do
        subject.should_receive(:puts).with("\n")
        subject.should_receive(:puts).with('title')
        subject.footer(:title => 'title')
      end

      it 'uses the defined spacing between report' do
        subject.should_receive(:puts).with("\n" * 3)
        subject.should_receive(:puts).with('title')
        subject.footer(:title => 'title', :spacing => 3)
      end
    end

    context 'timestamp subheading' do
      it 'is added with default alignment' do
        subject.should_receive(:puts).with("\n")
        subject.should_receive(:puts).with('title')
        subject.should_receive(:puts).with(/^#{@timestamp_regex}/)
        subject.footer(:title => 'title', :timestamp => true)
      end

      it 'added with right alignment' do
        subject.should_receive(:puts).with("\n")
        subject.should_receive(:puts).with(/^ *title$/)
        subject.should_receive(:puts).with(/^ *#{@timestamp_regex}$/)
        subject.header(:title => 'title', :align => 'right', :timestamp => true, :width => 80)
      end

      it 'added with center alignment' do
        subject.should_receive(:puts).with("\n")
        subject.should_receive(:puts).with(/^ *title *$/)
        subject.should_receive(:puts).with(/^ *#{@timestamp_regex} *$/)
        subject.header(:title => 'title', :align => 'center', :timestamp => true, :width => 80)
      end
    end

    context 'horizontal rule' do
      it 'uses dashes by default' do
        subject.should_receive(:puts)
        subject.should_receive(:puts).with('-' * 100)
        subject.should_receive(:puts)
        subject.footer(:rule => true)
      end

      it 'uses = as the rule character' do
        subject.should_receive(:puts)
        subject.should_receive(:puts).with('=' * 100)
        subject.should_receive(:puts)
        subject.footer(:rule => '=')
      end
    end
  end

  describe '#table' do
    it 'instantiates the table class' do
      subject.should_receive(:puts).any_number_of_times
      subject.should_receive(:table).once
      subject.table { }
      # subject.instance_variable_get(:@table).should_not be_nil
    end

    it 'requires a row to be defined' do
      expect {
        subject.table
      }.to raise_error LocalJumpError
    end

    it 'accepts valid options' do
      expect {
        subject.table(:width => 50) { }
      }.to_not raise_error
    end

    it 'rejects invalid options' do
      expect {
        subject.table(:asdf => '100') { }
      }.to raise_error ArgumentError
    end
  end

  describe '#row' do
    it 'instantiates a row class' do
      subject.should_receive(:row).once
      subject.should_receive(:puts).any_number_of_times

      subject.table do
        subject.row do
        end
      end
    end
  end

  describe '#column' do
    it 'instantiates multiple columns' do
      subject.should_receive(:column).exactly(3).times
      subject.should_receive(:puts).any_number_of_times

      subject.table do
        subject.row do
          subject.column('asdf')
          subject.column('qwer')
          subject.column('zxcv')
        end
      end
    end

    it 'accepts valid options' do
      subject.table do
        subject.row do
          subject.column('asdf', :width => 30)
        end
      end
    end

    it 'rejects invalid options' do
      expect {
        subject.table do
          subject.row do
            subject.column('asdf', :asdf => 30)
          end
        end
      }.to raise_error ArgumentError
    end
  end
end
