module CommandLineReporter
  attr_accessor :clr_indent, :clr_complete_string, :clr_indent_size

  def report(options = {})
    raise ArgumentError unless (options.keys - [:message, :type, :complete, :indent_size]).empty? && block_given?

    self.clr_indent = (self.clr_indent) ? self.clr_indent += 1 : 0

    padding = ' ' * self.clr_indent * (options[:indent_size] || self.clr_indent_size)

    start_str = "#{padding}#{options[:message]}"
    end_str = options[:complete] || self.clr_complete_string

    if options[:type] == 'inline'
      print "#{start_str}..."
    else
      puts start_str
      end_str = padding + end_str
    end

    yield

    puts end_str

    self.clr_indent -= 1
  end

  def clr_complete_string
    @clr_complete_string ||= 'complete'
  end

  def clr_indent_size
    @clr_indent_size ||= 2
  end
end
