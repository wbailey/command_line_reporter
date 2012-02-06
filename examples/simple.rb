require 'command_line_reporter'

include CommandLineReporter

class Example
  def initialize
    self.formatter = 'progress'
  end

  def run
    report do
      sum = 0
      10.times do
        sum += 10
        progress
      end
      vertical_spacing
      aligned("Sum: #{sum}")
    end
  end
end

Example.new.run
