require 'spec_helper'
require 'command_line_reporter'

describe CommandLineReporter do
  let :use_class do
    Class.new do
      include CommandLineReporter
    end
  end

  subject { use_class.new }

  describe '#header' do
    context 'argument validation' do
      it 'does not accept an invalid option' do
        lambda {
          subject.header(:asdf => 'tests')
        }.should raise_exception ArgumentError
      end

      it 'accepts a title as an option' do
        lambda {
          subject.should_receive(:puts).exactly(2).times
          subject.header(:title => 'test')
        }.should_not raise_exception ArgumentError
      end

      it 'accepts width as an option' do
        lambda {
          subject.should_receive(:puts).exactly(2).times
          subject.header(:width => '100')
        }.should_not raise_exception ArgumentError
      end

      it 'accepts align as an option' do
        lambda {
          subject.should_receive(:puts).exactly(2).times
          subject.header(:align => 'center')
        }.should_not raise_exception ArgumentError
      end

      it 'accepts spacing as an option' do
        lambda {
          subject.should_receive(:puts).exactly(2).times
          subject.header(:spacing => 2)
        }.should_not raise_exception ArgumentError
      end

      it 'accepts timestamp as an option' do
        lambda {
          subject.should_receive(:puts).exactly(3).times
          subject.header(:timestamp => true)
        }.should_not raise_exception ArgumentError
      end
    end

    context 'alignment' do
      before :each do
        @title = 'test11test'
      end

      it 'creates a left justified header by default' do
        subject.should_receive(:puts).with(@title)
        subject.should_receive(:puts).with("\n")
        subject.header(:title => @title) { }
      end

      it 'creates a left justified header' do
        subject.should_receive(:puts).with(@title)
        subject.should_receive(:puts).with("\n")
        subject.header(:title => @title, :align => 'left') { }
      end

      it 'creates a right justified header using default width' do
        subject.should_receive(:puts).with(' ' * 90 + @title)
        subject.should_receive(:puts).with("\n")
        subject.header(:title => @title, :align => 'right')
      end

      it 'creates a right justified header using specified width' do
        subject.should_receive(:puts).with(' ' * 40 + @title)
        subject.should_receive(:puts).with("\n")
        subject.header(:title => @title, :align => 'right', :width => 50)
      end

      it 'creates a center aligned header using default width' do
        subject.should_receive(:puts).with(' ' * 45 + @title)
        subject.should_receive(:puts).with("\n")
        subject.header(:title => @title, :align => 'center')
      end

      it 'creates a center aligned header using default width' do
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
      it 'adds a timestamp line' do
        subject.should_receive(:puts).with('title')
        subject.should_receive(:puts).with(/\d{4}-\d{2}-\d{2} *\d{2}:\d{2}:\d{2}/)
        subject.header(:title => 'title', :timestamp => true)
      end
    end
  end

  describe '#formatter=' do
    it 'only allows allowed formatters' do
      lambda {
        subject.formatter = 'asfd'
      }.should raise_exception ArgumentError
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
      $stdout = StringIO.new
      subject.report { }
      $stdout = STDOUT
      subject.formatter.class.should == CommandLineReporter::NestedFormatter
    end
  end
end
