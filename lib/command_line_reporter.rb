Dir[File.join(File.dirname(__FILE__), '*_formatter.rb')].each {|r| require r}

module CommandLineReporter
  attr_reader :formatter

  def report(options = {}, &block)
    self.formatter.format(options, block)
  rescue NoMethodError
    self.formatter = 'nested'
    retry
  end

  def header(options)
    allowed_options_keys = [:title, :width, :align, :spacing, :timestamp, :rule]

    raise ArgumentError unless (options.keys - allowed_options_keys).empty?

    title = options[:title] || 'Report'
    width = options[:width] || 100
    align = options[:align] || 'left'
    lines = options[:spacing] || 1

    # This also ensures that width is a Fixnum
    raise ArgumentError if title.size > width

    justified_text(title, align, width)

    datetime_text(align, width) if options[:timestamp]

    horizontal_rule(:char => options[:rule], :width => width) if options[:rule]

    vertical_spacing(lines)
  end

  def horizontal_rule(options = {})
    allowed_options_keys = [:char, :width]

    raise ArgumentError unless (options.keys - allowed_options_keys).empty?

    char = options[:char].is_a?(String) ? options[:char] : '-'
    width = options[:width] || 100

    puts char * width
  end

  def vertical_spacing(lines = 1)
    puts "\n" * lines
  end

  def formatter=(type = 'nested')
    name = type.capitalize + 'Formatter'
    klass = %W{CommandLineReporter #{name}}.inject(Kernel) {|s,c| s.const_get(c)}

    # Each formatter is a singleton that responds to #instance
    @formatter = klass.instance
  rescue
    raise ArgumentError, 'Invalid formatter specified'
  end

  private

  def datetime_text(align = 'left', width = 100)
    text = Time.now.strftime('%Y-%m-%d - %l:%M:%S%p')
    justified_text(text, align, width)
  end

  def justified_text(text, align = 'left', width = 100)
    case align
    when 'left'
      puts text
    when 'right'
      puts text.rjust(width)
    when 'center'
      puts text.rjust((width - text.size)/2 + text.size)
    else
      raise ArgumentError
    end
  end

end
