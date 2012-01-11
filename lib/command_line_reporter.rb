require 'table'

Dir[File.join(File.dirname(__FILE__), '*_formatter.rb')].each {|r| require r}

module CommandLineReporter
  include OptionsValidator

  attr_reader :formatter

  DEFAULTS = {
    :width => 100,
    :align => 'left',
  }

  def formatter=(type = 'nested')
    name = type.capitalize + 'Formatter'
    klass = %W{CommandLineReporter #{name}}.inject(Kernel) {|s,c| s.const_get(c)}

    # Each formatter is a singleton that responds to #instance
    @formatter = klass.instance
  rescue
    raise ArgumentError, 'Invalid formatter specified'
  end

  def header(options = {})
    section(:header, options)
  end

  def report(options = {}, &block)
    self.formatter ||= 'nested'
    self.formatter.format(options, block)
  end

  def footer(options = {})
    section(:footer, options)
  end

  def horizontal_rule(options = {})
    validate_options(options, :char, :width)

    char = options[:char].is_a?(String) ? options[:char] : '-'
    width = options[:width] || DEFAULTS[:width]

    puts char * width
  end

  def vertical_spacing(lines = 1)
    puts "\n" * lines
  rescue
    raise ArgumentError
  end

  def datetime(options = {})
    validate_options(options, :align, :width, :format)

    format = options[:format] || '%Y-%m-%d - %l:%M:%S%p'
    align = options[:align] || DEFAULTS[:align]
    width = options[:width] || DEFAULTS[:width]

    text = Time.now.strftime(format)

    raise Exception if text.size > width

    aligned(text, {:align => align, :width => width})
  end

  def aligned(text, options = {})
    validate_options(options, :align, :width)

    align = options[:align] || DEFAULTS[:align]
    width = options[:width] || DEFAULTS[:width]

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

  def table(options = {})
    @table = Table.new(options)
    yield
    @table.to_s
  end

  def row(options = {})
    @row = Row.new
    yield
    @table.add(@row)
  end

  def column(text, options = {})
    col = Column.new(text, options)
    @row.add(col)
  end

  private

  def section(type, options)
    validate_options(options, :title, :width, :align, :spacing, :timestamp, :rule)

    title = options[:title] || 'Report'
    width = options[:width] || DEFAULTS[:width]
    align = options[:align] || DEFAULTS[:align]
    lines = options[:spacing] || 1

    # This also ensures that width is a Fixnum
    raise ArgumentError if title.size > width

    if type == :footer
      vertical_spacing(lines)
      horizontal_rule(:char => options[:rule], :width => width) if options[:rule]
    end

    aligned(title, {:align => align, :width => width})
    datetime(:align => align, :width => width) if options[:timestamp]

    if type == :header
      horizontal_rule(:char => options[:rule], :width => width) if options[:rule]
      vertical_spacing(lines)
    end
  end
end
