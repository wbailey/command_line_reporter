require 'command_line_reporter'

class Example
  include CommandLineReporter

  def run
    records = [
      %w/asdf qwer zxcv/,
      %w/uip jkl bnm/,
    ]

    header(:title => 'Simple Report Example', :align => 'center', :timestamp => true, :rule => true)

    align = %w/left right center/

    2.times do |j|
      table(:width => 90, :border => j % 2 == 0) do
        10.times do
          row do
            i = 0
            3.times do
              i += 10
              column('x' * (1 + rand(49)), :align => align[rand(3)], :width => i)
            end
          end
        end
      end
    end

    table(:border => false) do
      row do
        column('Name', :width => 20)
        column('Address', :width => 30)
        column('City', :width => 15)
      end
    end

    horizontal_rule(:width => 65)

    table(:border => false) do
      row do
        column('Wes Bailey', :width => 20)
        column('1 Appian Way', :width => 30)
        column('Belmont', :width => 15)
      end
      row do
        column('Richard Feynman', :width => 20)
        column('1 Golden Gate', :width => 30)
        column('Heaven', :width => 15)
      end
    end
  end
end

Example.new.run
