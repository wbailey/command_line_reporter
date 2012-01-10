require 'options_validator'

class Column
  include OptionsValidator

  VALID_OPTIONS = [:width, :padding, :border, :align]
  attr_accessor :text, :size, *VALID_OPTIONS

  def initialize(text = nil, options = {})
    self.validate(options)

    self.text = text

    self.width = options[:width] || 10
    self.align = options[:align] || 'left'
    self.border = options[:border] || false
    self.padding = options[:padding] || (self.border ? 1 : 0)

    raise ArgumentError unless self.width > 0
    raise ArgumentError unless self.padding.to_s.match(/^\d+$/)

    self.size = self.width - 2 * self.padding

    self.freeze
  end

  def screen_rows
    if self.text.nil? || self.text.empty?
      [' ' * self.width]
    else
      chunk(self.size).map{|s| to_cell(s)}
    end
  end

  private

  def chunk(n)
    r = /.{#{n}}/
    self.text.scan(r) + self.text.split(r).reject(&:empty?)
  end

  def to_cell(str)
    cell = case self.align
    when 'left'
      self.text.ljust(self.size)
    when 'right'
      self.text.rjust(self.size)
    when 'center'
      self.text.ljust((self.size - self.text.size)/2.0 + self.text.size).rjust(self.size)
    end

    ' ' * self.padding + cell + ' ' * self.padding
  end
end
