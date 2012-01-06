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
    border_line
    first_char = self.border ? '|' : ' '
    self.rows.each do|row|
      row.columns.each do |col|
        last_char, compress_by = (row.columns.last == col) ? ['|', 2] : ['', 1]
        last_char = '' unless self.border
        print "#{first_char}#{col.text.ljust(col.width - compress_by)}#{last_char}"
      end
      print "\n"
      border_line
    end
  end

  private

  def border_line
    puts '+' + ('-' * (self.width - 2)) + '+' if self.border
  end
end
