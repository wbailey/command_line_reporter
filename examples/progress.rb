require 'command_line_reporter'

class Example
  include CommandLineReporter

  NYAN_CHARS = "****[;::;<](^-^)"

  def initialize
    self.formatter = 'progress'
  end

  def run
    x = 0

    report do
      10.times do
        x += 1
        sleep 0.1
        formatter.progress

        10.times do
          x += 1
          sleep 0.1
          formatter.progress
        end
      end
    end

    y = 0

    report do
      10.times do
        y += 1
        sleep 0.1
        formatter.progress("#{y*10}%")
      end
    end

    report do
      3.times do
        formatter.progress("\\")
        sleep 0.1
        formatter.progress("/")
        sleep 0.1
        formatter.progress("-")
        sleep 0.1
      end
    end

    report do
      100.times do
        self.formatter.progress(erase_chars + NYAN_CHARS)
        sleep 0.1
      end
    end

    aligned "x: #{x}"
    aligned "y: #{y}"
  end

  def erase_chars
    "\10" * NYAN_CHARS.size + " "
  end
end

Example.new.run
