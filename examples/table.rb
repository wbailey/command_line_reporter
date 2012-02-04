# recoil  <co>mmand_<li>ne_<re>porter
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

    header(:title => 'A simple example of how column properties are inherited from the first row')

    table(:border => true) do
      row(:header => true) do
        column('MY NAME IS REALLY LONG AND WILL WRAP AND HOPE', :width => 20, :align => 'center', :color => 'blue', :bold => true)
        column('ADDRESS', :width => 30, :color => 'red', :padding => 5)
        column('CITY', :width => 15, :color => 'red')
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
