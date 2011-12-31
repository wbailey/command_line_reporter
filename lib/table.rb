require 'row'
require 'forwardable'

class Table
  extend Forwardable

  attr_accessor :width, :padding, :border

  def initialize(options = {})
    raise ArgumentError unless (options.keys - [:width, :border, :padding]).empty?

    self.width = (options[:width] || 100).to_i
    self.border = options[:border] || false
    self.padding = (options[:padding] || 1).to_i

    raise ArgumentError unless self.width > 0 && self.padding > 0

    @rows = []
  end

  def_delegator :@rows, :push, :add_row
end
