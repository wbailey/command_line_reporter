require 'ansi'

module CommandLineReporter
  class Column
    include OptionsValidator

    VALID_OPTIONS = [:width, :padding, :align, :color, :color_code, :bold, :underline, :reversed]
    attr_accessor :text, :size, *VALID_OPTIONS

    def initialize(text = nil, options = {})
      self.validate_options(options, *VALID_OPTIONS)

      self.text = text.to_s

      self.width = options[:width]  || 10
      self.align = options[:align] || 'left'
      self.padding = options[:padding] || 0
      self.color = options[:color] || nil
      self.color_code = options[:color_code] || nil
      self.bold = options[:bold] || false
      self.underline = options[:underline] || false
      self.reversed = options[:reversed] || false

      raise ArgumentError unless self.width > 0
      raise ArgumentError unless self.padding.to_s.match(/^\d+$/)
    end

    def size
      self.width - 2 * self.padding
    end

    def required_width
      self.text.to_s.size + 2 * self.padding
    end

    def screen_rows
      if self.text.nil? || self.text.empty?
        [' ' * self.width]
      else
        self.text.scan(/.{1,#{self.size}}/m).map {|s| to_cell(s)}
      end
    end

    private

    def to_cell(str)
      # NOTE: For making underline and reversed work Change so that based on the
      # unformatted text it determines how much spacing to add left and right
      # then colorize the cell text
      cell =  str.empty? ? blank_cell : aligned_cell(str)
      padding_str = ' ' * self.padding
      padding_str + colorize(cell) + padding_str
    end

    def blank_cell
      ' ' * self.size
    end

    def aligned_cell(str)
      case self.align
      when 'left'
        str.ljust(self.size)
      when 'right'
        str.rjust(self.size)
      when 'center'
        str.ljust((self.size - str.size)/2.0 + str.size).rjust(self.size)
      end
    end

    def colorize(str)
      str = ANSI.public_send(color) { str } if self.color
      str = ANSI::Code.rgb(color_code) { str } if self.color_code
      str = ANSI.bold { str } if self.bold
      str
    end
  end
end
