require 'command_line_reporter'

class Example
  include CommandLineReporter

  def run
    header(:title => 'TABLE EXAMPLES - Borders, Wrapping, Alignment and Padding', :align => 'center', :width => 70)

    2.times do |j|
      header(:title => "Table #{j}", :align => 'center', :width => 65)

      table(:border => j % 2 == 0) do
        3.times do
          row do
            i = 0
            3.times do
              i += 10
              column('x' * (0 + rand(50)), :align => %w[left right center][rand(3)], :width => i, :padding => rand(5))
            end
          end
        end
      end

      vertical_spacing(2)
    end

    header(:title => 'A simple example of how column properties are inhereted from the first row')

    table(:border => true) do
      row do
        column('NAME', :width => 20)
        column('ADDRESS', :width => 30, :align => 'right', :padding => 5)
        column('CITY', :width => 15)
      end
      row do
        column('Ceaser')
        column('1 Appian Way')
        column('Rome')
      end
      row do
        column('Richard Feynman')
        column('1 Golden Gate')
        column('Quantum Field')
      end
    end
  end
end

Example.new.run
