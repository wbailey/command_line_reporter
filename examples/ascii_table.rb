require 'command_line_reporter'

class Example
  include CommandLineReporter

  def run
    example_simple
    vertical_spacing 2
    example_header
    vertical_spacing 2
    example_header
    vertical_spacing 2
    example_width
  end

  def example_simple
    header(:title => 'TABLE EXAMPLES - Borders, Wrapping, Alignment and Padding', :align => 'center', :width => 70)

    2.times do |j|
      header :title => "Table #{j}", :align => 'center', :width => 65

      table :border => j % 2 == 0, :encoding => :ascii do
        3.times do
          row do
            i = 0
            3.times do
              i += 10
              column 'x' * (0 + rand(50)), :align => %w[left right center][rand(3)], :width => i, :padding => rand(5) 
            end
          end
        end
      end

      vertical_spacing 2
    end
  end

  def example_header
    header :title => 'An example of a table with a header row.  The color and border properties are inherited from the first row'

    table :border => true, :encoding => :ascii do
      row :header => true, :color => 'red'  do
        column 'MY NAME IS REALLY LONG AND WILL WRAP AND HOPE', :width => 20, :align => 'center', :color => 'blue'
        column 'ADDRESS', :width => 30, :padding => 5
        column 'CITY', :width => 15
      end
      row :color => 'green', :bold => true do
        column 'caeser'
        column '1 Appian Way'
        column 'Rome'
      end
      row do
        column 'Richard Feynman'
        column '1 Golden Gate'
        column 'Quantum Field'
      end
    end
  end

  def example_inherit
    header :title => 'The same table without a header row so the properties inherited from it'

    table :border => true, :encoding => :ascii do
      row :color => 'red' do
        column 'MY NAME IS REALLY LONG AND WILL WRAP AND HOPE', :width => 20, :align => 'center', :color => 'blue'
        column 'ADDRESS', :width => 30, :padding => 5
        column 'CITY', :width => 15
      end
      row :color => 'green', :bold => true do
        column 'caeser'
        column '1 Appian Way'
        column 'Rome'
      end
      row do
        column 'Richard Feynman'
        column '1 Golden Gate'
        column 'Quantum Field'
      end
    end
  end

  def example_width
    header :title => 'A table with no width will determine width automatically'

    table :border => true, :width => :auto, :encoding => :ascii do
      row :color => 'red' do
        column 'MY NAME IS REALLY LONG AND WILL NOT WRAP', :align => 'center', :color => 'blue'
        column 'ADDRESS', :padding => 5
        column 'CITY'
      end
      row :color => 'green', :bold => true do
        column 'caeser'
        column '1 Appian Way'
        column 'Rome'
      end
      row do
        column 'Richard Feynman'
        column '1 Golden Gate'
        column 'Quantum Field'
      end
    end
  end
end

Example.new.run
