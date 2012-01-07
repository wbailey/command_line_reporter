require 'command_line_reporter'

class Example
  include CommandLineReporter

  def run
    records = [
      %w/asdf qwer zxcv/,
      %w/uip jkl bnm/,
    ]

    header(:title => 'Simple Report Example', :align => 'center', :timestamp => true, :rule => false)

    2.times do |j|
      table(:width => 90, :border => j % 2 == 0) do
        10.times do
          i = 0
          row do
            i += 10
            align = %w/left right center/[rand(3)]
            3.times do
              column('x' * rand(50), :align => align , :width => i)
            end
          end
        end
      end
    end

    footer(:title => 'Values', :width => 15)
  end
end

Example.new.run
