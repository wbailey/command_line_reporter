require 'stringio'

require 'command_line_reporter/options_validator'
require 'command_line_reporter/formatter/progress'
require 'command_line_reporter/formatter/nested'
require 'command_line_reporter/row'
require 'command_line_reporter/column'
require 'command_line_reporter/table'
require 'command_line_reporter/version'

module CommandLineReporter
  include OptionsValidator

  attr_reader :formatter

  DEFAULTS = {
    :width => 100,
    :align => 'left',
    :formatter => 'nested',
    :encoding => :unicode,
  }

  def capture_output
    $stdout.rewind
    $stdout.read
  ensure
    $stdout = STDOUT
  end

  def suppress_output
    $stdout = StringIO.new
  end

  def restore_output
    $stdout = STDOUT
  end

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
    self.formatter ||= DEFAULTS[:formatter]
    self.formatter.format(options, block)
  end

  def progress(override = nil)
    self.formatter.progress(override)
  end

  def footer(options = {})
    section(:footer, options)
  end

  def horizontal_rule(options = {})
    validate_options(options, :char, :width, :color, :color_code, :bold)

    # Got unicode?
    use_char = "\u2501" == 'u2501' ? '-' : "\u2501"

    char = options[:char].is_a?(String) ? options[:char] : use_char
    width = options[:width] || DEFAULTS[:width]

    aligned(char * width, :width => width, :color => options[:color], :color_code => options[:color_code], :bold => options[:bold])
  end

  def vertical_spacing(lines = 1)
    lines = Integer(lines)

    # because puts "\n" * 0 produces an unwanted newline
    if lines == 0
      print "\0"
    else
      puts "\n" * lines
    end
  end

  def datetime(options = {})
    validate_options(options, :align, :width, :format, :color, :color_code, :bold)

    format = options[:format] || '%Y-%m-%d - %l:%M:%S%p'
    align = options[:align] || DEFAULTS[:align]
    width = options[:width] || DEFAULTS[:width]

    text = Time.now.strftime(format)

    raise Exception if text.size > width

    aligned(text, :align => align, :width => width, :color => options[:color], :color_code => options[:color_code], :bold => options[:bold])
  end

  def aligned(text, options = {})
    validate_options(options, :align, :width, :color, :color_code, :bold)

    align = options[:align] || DEFAULTS[:align]
    width = options[:width] || DEFAULTS[:width]
    color = options[:color]
    color_code = options[:color_code]
    bold = options[:bold] || false

    line = case align
           when 'left'
             text
           when 'right'
             text.rjust(width)
           when 'center'
             text.rjust((width - text.size)/2 + text.size)
           else
             raise ArgumentError
           end

    line = ANSI.public_send(color) { line } if color
    line = ANSI::Code.rgb(color_code) { line } if color_code
    line = ANSI.bold { line } if bold

    puts line
  end

  def table(options = {})
    @table = CommandLineReporter::Table.new(options)
    yield
    @table.output
  end

  def row(options = {})
    options[:encoding] ||= @table.encoding
    @row = CommandLineReporter::Row.new(options)
    yield
    @table.add(@row)
  end

  def column(text, options = {})
    col = CommandLineReporter::Column.new(text, options)
    @row.add(col)
  end

  private

  def section(type, options)
    title, width, align, lines, color, color_code, bold = assign_section_properties(options)

    # This also ensures that width is a Fixnum
    raise ArgumentError if title.size > width

    if type == :footer
      vertical_spacing(lines)
      horizontal_rule(:char => options[:rule], :width => width, :color => color, :color_code => color_code, :bold => bold) if options[:rule]
    end

    aligned(title, :align => align, :width => width, :color => color, :bold => bold)
    datetime(:align => align, :width => width, :color => color, :color_code => color_code, :bold => bold) if options[:timestamp]

    if type == :header
      horizontal_rule(:char => options[:rule], :width => width, :color => color, :color_code => color_code, :bold => bold) if options[:rule]
      vertical_spacing(lines)
    end
  end

  def assign_section_properties options
    validate_options(options, :title, :width, :align, :spacing, :timestamp, :rule, :color, :color_code, :bold)

    title = options[:title] || 'Report'
    width = options[:width] || DEFAULTS[:width]
    align = options[:align] || DEFAULTS[:align]
    lines = options[:spacing] || 1
    color = options[:color]
    color_code = options[:color_code]
    bold = options[:bold] || false

    return [title, width, align, lines, color, color_code, bold]
  end
end
