require 'options_validator'
require 'colored'

module CommandLineReporter
  class Column
    include OptionsValidator

    VALID_OPTIONS = [:width, :padding, :align, :color, :bold, :underline, :reversed]
    attr_accessor :text, :size, *VALID_OPTIONS

    def initialize(text = nil, options = {})
      self.validate_options(options, *VALID_OPTIONS)

      self.text = text

      self.width = options[:width] || 10
      self.align = options[:align] || 'left'
      self.padding = options[:padding] || 0
      self.color = options[:color] || nil
      self.bold = options[:bold] || false
      self.underline = options[:underline] || false
      self.reversed = options[:reversed] || false

      raise ArgumentError unless self.width > 0
      raise ArgumentError unless self.padding.to_s.match(/^\d+$/)

      self.size = self.width - 2 * self.padding
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
      cell =  if str.empty?
                ' ' * self.size
              else
                case self.align
                when 'left'
                  str.ljust(self.size)
                when 'right'
                  str.rjust(self.size)
                when 'center'
                  str.ljust((self.size - str.size)/2.0 + str.size).rjust(self.size)
                end
              end

      padding_str = ' ' * self.padding
      padding_str + add_color(cell) + padding_str
    end

    def add_color(str)
      color_chain = []
      color_chain << self.color unless self.color.nil?
      color_chain << 'bold' if self.bold
      color_chain << 'underline' if self.underline
      color_chain << 'reversed' if self.reversed
      color_chain.inject(str) {|s,v| s.send(v)}
    end
  end
end
