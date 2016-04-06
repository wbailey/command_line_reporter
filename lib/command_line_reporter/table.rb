module CommandLineReporter
  class Table
    include OptionsValidator

    VALID_OPTIONS = [:border, :width, :encoding].freeze
    attr_accessor :rows, *VALID_OPTIONS

    def initialize(options = {})
      validate_options(options, *VALID_OPTIONS)

      self.border = options[:border] || false
      self.width = options[:width] || false
      self.encoding = options[:encoding] || CommandLineReporter::DEFAULTS[:encoding]

      @rows = []

      raise ArgumentError, 'Invalid encoding' unless [:ascii, :unicode].include? encoding
    end

    def add(row)
      # Inheritance from the table
      row.border = border

      # Inherit properties from the appropriate row
      inherit_column_attrs(row) if rows[0]

      rows << row
    end

    def output
      return if rows.size == 0 # we got here with nothing to print to the screen
      auto_adjust_widths if width == :auto

      puts separator('first') if border
      rows.each_with_index do |row, index|
        row.output
        puts separator('middle') if border && (index != rows.size - 1)
      end
      puts separator('last') if border
    end

    def auto_adjust_widths
      column_widths = []

      rows.each do |row|
        row.columns.each_with_index do |col, i|
          column_widths[i] = [col.required_width, (column_widths[i] || 0)].max
        end
      end

      rows.each do |row|
        row.columns.each_with_index do |col, i|
          col.width = column_widths[i]
        end
      end
    end

    private

    def separator(type = 'middle')
      left, center, right, bar = use_utf8? ? utf8_separator(type) : ascii_separator

      left + rows[0].columns.map { |c| bar * (c.width + 2) }.join(center) + right
    end

    def use_utf8?
      encoding == :unicode && "\u2501" != 'u2501'
    end

    def ascii_separator
      left = right = center = '+'
      bar = '-'
      [left, right, center, bar]
    end

    def utf8_separator(type)
      bar = "\u2501"

      left, center, right = case type
                            when 'first'
                              ["\u250F", "\u2533", "\u2513"]
                            when 'middle'
                              ["\u2523", "\u254A", "\u252B"]
                            when 'last'
                              ["\u2517", "\u253B", "\u251B"]
                            end

      [left, center, right, bar]
    end

    def inherit_column_attrs(row)
      row.columns.each_with_index do |c, i|
        use_positional_attrs(c, i)
        use_color(row, c, i)
        use_bold(row, c, i)
      end
    end

    def use_positional_attrs(c, i)
      # The positional attributes are always required to inheret to make sure the table
      # displays properly
      %w(align padding width).each do |attr|
        val = rows[0].columns[i].send(attr)
        c.send(attr + '=', val)
      end
    end

    def inherit_from
      rows[0].header ? 1 : 0
    end

    def use_color(row, c, i)
      if c.color
        # keep default
      elsif row.color
        c.color = row.color
      elsif inherit_from != 1
        c.color = rows[inherit_from].columns[i].color
      end
    end

    def use_bold(row, c, i)
      if row.bold
        c.bold = row.bold
      elsif inherit_from != 1
        c.bold = rows[inherit_from].columns[i].bold
      end
    end
  end
end
