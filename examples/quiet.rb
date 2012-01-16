require 'command_line_reporter'
require 'ostruct'
require 'optparse'

class Example
  include CommandLineReporter

  def initialize
    self.formatter = 'progress'
  end

  def run(options = {})
    x = 0

    suppress_output if options.quiet

    report do
      10.times do
        x += 1
        sleep 0.1
        formatter.progress
      end
    end

    restore_output if options.quiet
  end
end


options = OpenStruct.new({:quiet => false})

OptionParser.new do |opts|
  opts.banner = "Usage: ruby -I lib example/quiet.rb [-q|--quiet]"

  opts.on('-q', '--quiet', 'do not print any output') do
    options.quiet = true
  end
end.parse!

Example.new.run(options)
