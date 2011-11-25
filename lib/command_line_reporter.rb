require 'nested_formatter'

module CommandLineReporter
  attr_accessor :clr_formatter, :clr_indent, :clr_message_str, :clr_complete_string, :clr_indent_size

  def report(options = {}, &block)
    case self.clr_formatter
    when 'progress'
      clr_progress_formatter(block)
    when 'nested'
      clr_nested_formatter(options, block)
    end
  end

  def clr_formatter
    @clr_formatter ||= 'nested'
  end

  def clr_message_string
    @clr_message_string ||= 'working'
  end

  def clr_complete_string
    @clr_complete_string ||= 'complete'
  end

  def clr_indent_size
    @clr_indent_size ||= 2
  end

  private

  def clr_nested_formatter(options, block)
    raise ArgumentError unless (options.keys - [:message, :type, :complete, :indent_size]).empty? && !block.nil?

    self.clr_indent = (self.clr_indent) ? self.clr_indent += 1 : 0

    padding = ' ' * self.clr_indent * (options[:indent_size] || self.clr_indent_size)

    message_str = padding + (options[:message] || self.clr_message_string)
    complete_str = options[:complete] || self.clr_complete_string

    if options[:type] == 'inline'
      print "#{message_str}..."
    else
      puts message_str
      complete_str = padding + complete_str
    end

    block.call

    puts complete_str

    self.clr_indent -= 1
  end
end
