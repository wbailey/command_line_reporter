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
    spacing = "\n" * (options[:spacing] || 1)
    timestamp = options[:timestamp] || false

    case align
    when 'left'
      puts title
    when 'right'
      puts title.rjust(width)
    when 'center'
      puts title.rjust((width - title.size)/2 + title.size)
    end

    if timestamp
      date = Time.now.strftime('%Y-%m-%d')
      time = Time.now.strftime('%l:%M:%S%p')
      padding = width - date.size - time.size
      puts date + (' ' * padding) + time
    end

    puts spacing
  end

  def formatter=(type = 'nested')
    name = type.capitalize + 'Formatter'
    klass = %W{CommandLineReporter #{name}}.inject(Kernel) {|s,c| s.const_get(c)}

    # Each formatter is a singleton that responds to #instance
    @formatter = klass.instance
  rescue
    raise ArgumentError, 'Invalid formatter specified'
  end
end
