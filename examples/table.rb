require 'command_line_reporter'

class Example
  include CommandLineReporter

  def run
    records = [
      %w/asdf qwer zxcv/,
      %w/uip jkl bnm/,
    ]

    header(:title => 'Simple Report Example', :align => 'center', :timestamp => true, :rule => false)

    align = %w/left right center/

    2.times do |j|
      table(:width => 90, :border => j % 2 == 0) do
        10.times do
          row do
            i = 0
            3.times do
              i += 10
              column('x' * rand(10), :align => align[rand(3)], :width => i)
            end
          end
        end
      end
    end

    footer(:title => 'Values', :width => 15)
  end
end

Example.new.run
