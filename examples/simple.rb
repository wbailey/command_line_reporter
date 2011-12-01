require 'command_line_reporter'

class Example
  include CommandLineReporter

  def run
    x,y,z = 0,0,0

    header(:title => 'Simple Report Example', :align => 'center', :timestamp => true, :rule => true)

    report(:message => 'calculating sums') do
      x = 2 + 2
      y = 10 - x
      z = x + y
    end

    footer(:title => 'Values', :width => 15)
    %w(x y z).each {|v| aligned("#{v}: #{eval v}")}
  end
end

Example.new.run
