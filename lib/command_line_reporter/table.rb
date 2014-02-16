module CommandLineReporter
  class Table
    include OptionsValidator

    VALID_OPTIONS = [:border, :width, :encoding]
    attr_accessor :rows, *VALID_OPTIONS

    def initialize(options = {})
      self.validate_options(options, *VALID_OPTIONS)

      self.border = options[:border] || false
      self.width = options[:width] || false
      self.encoding = options[:encoding] || CommandLineReporter::DEFAULTS[:encoding]

      @rows = []

      raise ArgumentError, "Invalid encoding" unless [ :ascii, :unicode ].include? self.encoding
    end

    def add(row)
      # Inheritance from the table
      row.border = self.border

      # Inherit properties from the appropriate row
      if self.rows[0]
        row.columns.each_with_index do |c,i|
          # The positional attributes are always required to inheret to make sure the table
          # displays properly
          c.align = self.rows[0].columns[i].align
          c.padding = self.rows[0].columns[i].padding
          c.width = self.rows[0].columns[i].width
          c.color = use_color(row, c, i)
          c.bold = use_bold(row, c, i)

          #unless row.color || c.color
            #if self.rows[0].header
              #c.color = self.rows[1].columns[i].color if self.rows[1]
            #else
              #c.color = self.rows[0].columns[i].color
            #end
          #end

          # Allow for the row to take precendence and that the first # row might be a header
          # row which we don't want to inherit from
          #unless row.bold
            #if self.rows[0].header
              #c.bold = self.rows[1].columns[i].bold if self.rows[1]
            #else
              #c.bold = self.rows[0].columns[i].bold
            #end
          #end
        end
      end

      self.rows << row
    end

    def output
      return if self.rows.size == 0 # we got here with nothing to print to the screen
      auto_adjust_widths if self.width == :auto

      puts separator('first') if self.border
      self.rows.each_with_index do |row, index|
        row.output
        puts separator('middle') if self.border && (index != self.rows.size - 1)
      end
      puts separator('last') if self.border
    end

    def auto_adjust_widths
      column_widths = []

      self.rows.each do |row|
        row.columns.each_with_index do |col, i|
          column_widths[i] = [ col.required_width, ( column_widths[i] || 0 ) ].max
        end
      end

      self.rows.each do |row|
        row.columns.each_with_index do |col, i|
          col.width = column_widths[i]
        end
      end
    end

    private

    def separator(type = 'middle')
      if "\u2501" == 'u2501' || self.encoding == :ascii
        left = right = center = '+'
        bar = '-'
      else
        bar = "\u2501"
        case type
        when 'first'
          left = "\u250F"
          center = "\u2533"
          right = "\u2513"
        when 'middle'
          left = "\u2523"
          center = "\u254A"
          right = "\u252B"
        when 'last'
          left = "\u2517"
          center = "\u253B"
          right = "\u251B"
        end
      end

      left + self.rows[0].columns.map {|c| bar * (c.width + 2)}.join(center) + right
    end

    def inherit_from
      if self.rows.size == 0
        raise RuntimeError
      elsif self.rows[0] && !self.rows[0].header
        0
      elsif self.rows[0].header && self.rows[1]
        1
      else
        0
      end
    end

    def use_color(row, column, index)
      if column.color
        column.color
      elsif row.color
        row.color
      else
        self.rows[inherit_from].columns[index].color
      end
    end

    def use_bold(row, column, index)
      if column.bold
        column.bold
      elsif row.bold
        row.bold
      else
        self.rows[inherit_from].columns[index].bold
      end
    end
  end
end
