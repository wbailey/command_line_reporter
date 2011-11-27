require 'command_line_reporter'

class Example
  include CommandLineReporter

  def initialize
    self.formatter = 'progress'
  end

  def run
    x = 0

    report do
      10.times do
        x += 1
        formatter.progress

        10.times do
          x += 1
          formatter.progress
        end
      end
    end

    y = 0

    report do
      10.times do
        y += 1
        sleep 1
        formatter.progress("#{y*10+10}%")
      end
    end

    report do
      3.times do
        formatter.progress("\\")
        sleep 1
        formatter.progress("/")
        sleep 1
        formatter.progress("-")
        sleep 1
      end
    end

    puts "x: #{x}"
    puts "y: #{y}"
  end
end

Example.new.run
