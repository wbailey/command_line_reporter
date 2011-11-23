module CommandLineReporter
  attr_accessor :command_line_reporter_indent, :command_line_reporter_complete_string, :command_line_reporter_indent_size

  def report(options = {})
    raise ArgumentError unless (options.keys - [:message, :type, :complete, :indent_size]).empty?

    self.command_line_reporter_indent = (self.command_line_reporter_indent) ? self.command_line_reporter_indent += 1 : 0

    padding = ' ' * self.command_line_reporter_indent * (options[:indent_size] || self.command_line_reporter_indent_size)

    start_str = "#{padding}#{options[:message]}"
    end_str = options[:complete] || self.command_line_reporter_complete_string

    if options[:type] == 'inline'
      print "#{start_str}..."
    else
      puts start_str
      end_str = padding + end_str
    end

    yield

    puts end_str

    self.command_line_reporter_indent -= 1
  end

  def command_line_reporter_complete_string
    @command_line_reporter_complete_string ||= 'complete'
  end

  def command_line_reporter_indent_size
    @command_line_reporter_indent_size ||= 2
  end
end

class Example
  attr_accessor :expresssions

  include CommandLineReporter

  def initialize
    self.command_line_reporter_complete_string = 'done'
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
            report(:message => 'pixelizing', :type => 'inline', :complete => "#{i*10}%") do
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
