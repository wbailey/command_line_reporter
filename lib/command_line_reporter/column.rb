require 'colored'

module CommandLineReporter
  class Column
    include OptionsValidator

    VALID_OPTIONS = %i[width padding align color bold underline reversed].freeze
    attr_accessor :text, :size, *VALID_OPTIONS

    def initialize(text = nil, options = {})
      validate_options(options, *VALID_OPTIONS)
      assign_alignment_defaults(options)
      assign_color_defaults(options)

      begin
        width.positive?
      rescue
        raise ArgumentError
      end

      raise ArgumentError unless padding.to_s.match?(/^\d+$/)

      self.text = text.to_s
    end

    def size
      width - 2 * padding
    end

    def required_width
      text.to_s.size + 2 * padding
    end

    def screen_rows
      if text.nil? || text.empty?
        [' ' * width]
      else
        text.scan(/.{1,#{size}}/m).map { |s| to_cell(s) }
      end
    end

    private

    def assign_alignment_defaults(options)
      self.width = options[:width] || 10
      self.align = options[:align] || 'left'
      self.padding = options[:padding] || 0
    end

    def assign_color_defaults(options)
      self.color = options[:color] || nil
      self.bold = options[:bold] || false
      self.underline = options[:underline] || false
      self.reversed = options[:reversed] || false
    end

    def to_cell(str)
      # NOTE: For making underline and reversed work Change so that based on the
      # unformatted text it determines how much spacing to add left and right
      # then colorize the cell text
      cell =  str.empty? ? blank_cell : aligned_cell(str)
      padding_str = ' ' * padding
      padding_str + colorize(cell) + padding_str
    end

    def blank_cell
      ' ' * size
    end

    def aligned_cell(str)
      case align
      when 'left'
        str.ljust(size)
      when 'right'
        str.rjust(size)
      when 'center'
        str.ljust((size - str.size) / 2.0 + str.size).rjust(size)
      end
    end

    def colorize(str)
      str = str.send(color) if color
      str = str.send('bold') if bold
      str
    end
  end
end
