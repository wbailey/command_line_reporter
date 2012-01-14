require 'options_validator'

class Column
  include OptionsValidator

  VALID_OPTIONS = [:width, :padding, :align, :formatter]
  attr_accessor :text, :size, *VALID_OPTIONS

  def initialize(text = nil, options = {})
    self.validate_options(options, *VALID_OPTIONS)

    self.text = text

    self.width = options[:width] || 10
    self.align = options[:align] || 'left'
    self.padding = options[:padding] || 0
    self.formatter = options[:formatter]

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

    ' ' * self.padding + cell + ' ' * self.padding
  end
end
