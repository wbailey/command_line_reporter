require 'options_validator'

class Column
  include OptionsValidator

  VALID_OPTIONS = [:width, :padding, :border, :align]
  attr_accessor :text, :size, *VALID_OPTIONS

  def initialize(text, options = {})
    self.validate(options)

    self.text = text

    self.width = options[:width] || 10
    self.padding = options[:padding] || 1
    self.align = options[:align] || 'left'
    self.border = options[:border] || ''

    raise ArgumentError unless self.width > 0 && self.padding > 0

    self.size = self.width - 2 * self.padding

    self.freeze
  end

  def screen_rows
    chunk(self.size).map{|s| apply_border(s)}
  end

  private

  def chunk(n)
    r = /.{#{n}}/
    self.text.scan(r) + self.text.split(r).reject(&:empty?)
  end

  def apply_border(str)
    case self.align
    when 'left'
      "" + self.border + str.rjust(padding + str.size).ljust(self.width) +  self.border
    end
  end
end
