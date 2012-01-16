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

    table do
      row do
        column('x', :width => 5, :align => 'right')
        column(x.to_s, :width => 10)
      end
      row do
        column('y')
        column(y.to_s)
      end
      row do
        column('z')
        column(z.to_s)
      end
    end
  end
end

Example.new.run
