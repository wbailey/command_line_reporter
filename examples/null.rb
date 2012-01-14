require 'command_line_reporter'

class Example
  include CommandLineReporter

  def initialize
    # Using the null formatter suppresses all output
    self.formatter = 'null'
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

    aligned "x: #{x}"

    # formatter.puts also does nothing in the null formatter
    formatter.puts  "Ready to exit"
    # but Kernel.puts is unchanged
    puts "Done!"
    puts x
  end

end

Example.new.run
