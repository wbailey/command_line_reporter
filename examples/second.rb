require 'command_line_reporter'

class Example
  include CommandLineReporter

  def initialize
    self.formatter = 'nested'
    self.formatter.complete_string = 'done'
  end

  def run
    x,y,z = 0,0,0

    report(:message => 'calculating first expression') do
      x = 2 + 2
      sleep 1

      2.times do
        report(:message => 'calculating second expression') do
          y = 10 - x
          sleep 1

          10.times do |i|
            report(:message => 'pixelizing', :type => 'inline', :complete => "#{i*10+10}%") do
              z = x + y
              sleep 1
            end
          end
        end
      end
    end

    puts '-' * 20
    %w(x y z).each {|v| puts "#{v}: #{eval v}"}
  end
end

Example.new.run
