require 'column'
require 'forwardable'

class Row
  extend Forwardable

  attr_accessor :columns

  def initialize(columns = [])
    self.columns = columns
  end

  def_delegator :@columns, :push, :add
end
