require 'command_line_reporter'

class Example
  include CommandLineReporter

  def run
    records = [
      %w/asdf qwer zxcv/,
      %w/uip jkl bnm/,
    ]

    header(:title => 'Simple Report Example', :align => 'center', :timestamp => true, :rule => false)

    table(:width => 90, :border => false) do
      records.each do |record|
        row do
          record.each do |val|
            column(val, :align => 'left')
          end
        end
      end
    end

    footer(:title => 'Values', :width => 15)
  end
end

Example.new.run
