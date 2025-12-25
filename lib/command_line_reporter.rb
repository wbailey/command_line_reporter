require 'stringio'

require 'command_line_reporter/options_validator'
require 'command_line_reporter/formatter/progress'
require 'command_line_reporter/formatter/nested'
require 'command_line_reporter/row'
require 'command_line_reporter/column'
require 'command_line_reporter/table'
require 'command_line_reporter/version'

# rubocop:disable Metrics/ModuleLength
module CommandLineReporter
  include OptionsValidator

  attr_reader :formatter

  DEFAULTS = {
    width: 100,
    align: 'left',
    formatter: 'nested',
    encoding: :unicode
  }.freeze

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
    unless type.is_a?(String)
      @formatter = type
      return
    end

    name = "#{type.capitalize}Formatter"
    klass = %W[CommandLineReporter #{name}].inject(Kernel) { |a, e| a.const_get(e) }

    # Each formatter is a singleton that responds to #instance
    @formatter = klass.instance
  rescue StandardError
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
    validate_options(options, :char, :width, :color, :bold)

    # Got unicode?
    use_char = "\u2501" == 'u2501' ? '-' : "\u2501"

    char = options[:char].is_a?(String) ? options[:char] : use_char
    width = options[:width] || DEFAULTS[:width]

    aligned(char * width, width: width, color: options[:color], bold: options[:bold])
  end

  def vertical_spacing(lines = 1)
    lines = Integer(lines)

    # because puts "\n" * 0 produces an unwanted newline
    if lines.zero?
      print "\0"
    else
      puts "\n" * lines
    end
  end

  def datetime(options = {})
    validate_options(options, :align, :width, :format, :color, :bold)

    format = default_options_date_format(options[:format])
    text = Time.now.strftime(format)

    aligned(text, options)
  end

  def aligned(text, options = {})
    validate_options(options, :align, :width, :format, :color, :bold)

    options[:align] = default_options_align(options[:align])
    options[:width] = default_options_width(options[:width])
    options[:bold] = default_options_bold(options[:bold])

    raise ArgumentError, 'Text is wider than the available width' if text.size > options[:width]

    line = align_line(text, options)

    puts apply_color(line, options)
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

  def align_line(text, options)
    case options[:align]
    when 'left'
      text
    when 'right'
      text.rjust(options[:width])
    when 'center'
      text.rjust(((options[:width] - text.size) / 2) + text.size)
    end
  end

  def apply_color(line, options)
    line = line.send(options[:color]) if options[:color]
    line = line.send('bold') if options[:bold]
    line
  end

  # def default_datetime_options(options)
  #   format = define_format(options)
  #   align = default_options_align(options[:align])
  #   width = default_options_width(options[:width])
  #   [format, align, width]
  # end

  def default_options_date_format(format)
    format || '%Y-%m-%d - %l:%M:%S%p'
  end

  def section(type, options)
    options = define_section_values(options)

    raise ArgumentError if options[:title].size > options[:width]

    print_header(type, options)
    print_body(options)
    print_footer(type, options)
  end

  def print_header(type, options)
    return unless type == :header

    vertical_spacing(options[:lines])
    horizontal_rule(char: options[:rule], width: options[:width], color: options[:color], bold: options[:bold]) if options[:rule]
  end

  def print_body(options)
    aligned(options[:title], align: options[:align], width: options[:width], color: options[:color], bold: options[:bold])
    datetime(align: options[:align], width: options[:width], color: options[:color], bold: options[:bold]) if options[:timestamp]
  end

  def print_footer(type, options)
    return unless type == :footer

    horizontal_rule(char: options[:rule], width: options[:width], color: options[:color], bold: options[:bold]) if options[:rule]
    vertical_spacing(options[:lines])
  end

  def define_section_values(options)
    validate_options(options, :title, :width, :align, :spacing, :timestamp, :rule, :color, :bold)

    options[:title] = default_options_title(options[:title])
    options[:width] = default_options_width(options[:width])
    options[:align] = default_options_align(options[:align])
    options[:lines] = default_options_lines(options[:spacing])
    options[:bold] = default_options_bold(options[:bold])

    options
  end

  def default_options_title(title)
    title || 'Report'
  end

  def default_options_width(width)
    width ||= DEFAULTS[:width]
    Integer(width)
    width
  end

  def default_options_align(align)
    align ||= DEFAULTS[:align]
    validate_align(align)
    align
  end

  def default_options_lines(lines)
    lines || 1
  end

  def default_options_bold(bold)
    bold || false
  end

  def validate_align(align)
    raise ArgumentError unless %i[left center right].include?(align.to_sym)
  end
end
# rubocop:enable Metrics/ModuleLength
