require 'command_line_reporter'

class Example
  include CommandLineReporter

  def initialize
    self.formatter = 'progress'
  end

  def run
    suppress_output 

    report do
      sum = 0
      10.times do
        sum += 10
        progress
      end
      vertical_spacing
      aligned("Sum: #{sum}")
    end

    capture_output
  end
end

out = Example.new.run

puts 'this could be stored in a database'
puts out
