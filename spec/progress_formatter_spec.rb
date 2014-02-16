require 'spec_helper'

describe CommandLineReporter::ProgressFormatter do
  subject { CommandLineReporter::ProgressFormatter.instance }

  describe '#method default values' do
    describe '#indicator' do
      subject { super().indicator }
      it { should == '.' }
    end
  end

  let :controls do
    {
      :clear => "\e[0m",
      :bold => "\e[1m",
      :red => "\e[31m",
    }
  end

  describe '#format' do
    it 'displays dots for the indicator' do
      expect(subject).to receive(:print).exactly(10).times.with('.')
      expect(subject).to receive(:puts).exactly(1).times

      subject.format({}, lambda {
        10.times {subject.progress}
      })
    end

    it 'displays colored red dots for the indicator' do
      expect(subject).to receive(:print).exactly(10).times.with("#{controls[:red]}.#{controls[:clear]}")
      expect(subject).to receive(:puts).exactly(1).times

      subject.format({:color => 'red'}, lambda {
        10.times {subject.progress}
      })
    end

    it 'displays BOLD dots for the indicator' do
      expect(subject).to receive(:print).exactly(10).times.with("#{controls[:bold]}.#{controls[:clear]}")
      expect(subject).to receive(:puts).exactly(1).times

      subject.format({:bold => true}, lambda {
        10.times {subject.progress}
      })
    end

    it 'uses the defined indicator' do
      subject.indicator = '+'
      expect(subject).to receive(:print).exactly(10).times.with('+')
      expect(subject).to receive(:puts)

      subject.format({}, lambda {
        10.times {subject.progress}
      })

    end

    it 'allows override of the indicator' do
      expect(subject).to receive(:print).exactly(10).times.with('=')
      expect(subject).to receive(:puts)

      subject.format({:indicator => '='}, lambda {
        10.times {subject.progress}
      })
    end
  end

  describe '#progress' do
    it 'allows override of the indicator' do
      expect(subject).to receive(:print).exactly(10).times.with('+')
      expect(subject).to receive(:puts)

      subject.format({}, lambda {
        10.times {subject.progress('+')}
      })
    end

    it 'allows any indicator' do
      expect(subject).to receive(:print).exactly(10).times
      expect(subject).to receive(:puts)

      subject.format({}, lambda {
        10.times {|i| subject.progress("#{i}")}
      })
    end
  end
end
