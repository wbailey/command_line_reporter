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
    return if self.rows.size == 0 # we got here with nothing to print to the screen
    puts self.rows[0].seperator if self.border
    self.rows.each {|row| row.to_s(self.border)}
  end
end
