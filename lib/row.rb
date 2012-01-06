require 'column'
require 'forwardable'

class Row
  extend Forwardable

  attr_accessor :columns

  def initialize
    self.columns = []
  end

  def_delegator :@columns, :push, :add
end
