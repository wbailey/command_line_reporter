require 'row'
require 'forwardable'
require 'options_validator'

class Table
  extend Forwardable

  include OptionsValidator

  VALID_OPTIONS = [:width, :border, :padding]
  attr_accessor :rows, *VALID_OPTIONS

  def initialize(options = {})
    self.validate(options)

    self.width = (options[:width] || 100).to_i
    self.border = options[:border] || false
    self.padding = (options[:padding] || 1).to_i

    raise ArgumentError unless self.width > 0 && self.padding > 0

    @rows = []
  end

  def_delegator :@rows, :push, :add_row

  def to_s
    if self.border
      header = '+' + self.rows[0].columns.map {|c| '-' * (c.size + 2)}.join('+') + '+'

      puts header
      self.rows.each do |row|
        puts '|' + row.columns.map {|c| to_cell(c) }.join('|') + '|'
        puts header
      end
    else
      self.rows.each do |row|
        puts row.columns.map {|c| to_cell(c)}.join(' ')
      end
    end
  end

  private

  def to_cell(c)
    text = case c.align
       when 'left'
         c.text.ljust(c.size)
       when 'right'
         c.text.rjust(c.size)
       when 'center'
         spacing = (c.size - c.text.size)/2
         c.text.ljust(c.size - spacing).rjust(c.size)
       end
    " #{text} "
  end
end
