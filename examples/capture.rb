require 'command_line_reporter'

class Example
  include CommandLineReporter

  def run
    suppress_output

    table :border => true do
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

    return capture_output
  end
end

# All the content is now in the report variable
report = Example.new.run

puts report
