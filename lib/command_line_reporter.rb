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
    raise ArgumentError unless (options.keys - [:title, :width, :align, :spacing, :timestamp]).empty?

    title = options[:title] || 'Report'
    width = options[:width] || 100
    align = options[:align] || 'left'

    # This also ensures that width is a Fixnum
    raise ArgumentError if title.size > width

    puts_aligned_text(title, align, width)

    if options[:timestamp]
      text = Time.now.strftime('%Y-%m-%d - %l:%M:%S%p')
      puts_aligned_text(text, align, width)
    end

    puts "\n" * (options[:spacing] || 1)
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

  def puts_aligned_text(text, align, width)
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
