require 'column'
require 'forwardable'

class Row
  extend Forwardable

  attr_accessor :columns

  def initialize
    self.columns = []
  end

  def_delegator :@columns, :push, :add

  def screen_count
    self.columns.inject(0) {|max,column| column.screen_rows.size > max ? column.screen_rows.size : max}
  end

  def seperator
    @sep ||= '+' + self.columns.map {|c| '-' * (c.size + 2)}.join('+') + '+'
  end

  def to_s(border)
    self.screen_count.times do |sr|
      line = (border) ? '| ' : ''
      self.columns.size.times do |mc|
        line <<  self.columns[mc].screen_rows[sr] + ' ' + ((border) ? '| ' : '')
      end
      puts line
      puts self.seperator if border
    end
  end
end
