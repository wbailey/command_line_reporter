require 'column'
require 'forwardable'

class Row
  extend Forwardable

  attr_accessor :columns, :border

  def initialize(options = {})
    self.columns = []
    self.border = false
  end

  def_delegator :@columns, :push, :add

  def separator
    @sep ||= '+' + self.columns.map {|c| '-' * (c.width + 2)}.join('+') + '+'
  end

  def output
    screen_count.times do |sr|
      line = (self.border) ? '| ' : ''
      self.columns.size.times do |mc|
        col = self.columns[mc]
        # Account for the fact that some columns will have more screen rows than their
        # counterparts in the row.  An example being:
        # c1 = Column.new('x' * 50, :width => 10)
        # c2 = Column.new('x' * 20, :width => 10)
        #
        # c1.screen_rows.size == 5
        # c2.screen_rows.size == 2
        #
        # So when we don't have a screen row for c2 we need to fill the screen with the 
        # proper number of blanks so the layout looks like (parenthesis on the right just
        # indicate screen row index)
        #
        # +-------------+------------+
        # | xxxxxxxxxxx | xxxxxxxxxx | (0)
        # | xxxxxxxxxxx | xxxxxxxxxx | (1)
        # | xxxxxxxxxxx |            | (2)
        # | xxxxxxxxxxx |            | (3)
        # | xxxxxxxxxxx |            | (4)
        # +-------------+------------+
        if col.screen_rows[sr].nil?
          line << ' ' * col.width
        else
          line <<  self.columns[mc].screen_rows[sr]
        end
        line << ' ' + ((self.border) ? '| ' : '')
      end
      puts line
    end
  end

  private

  def screen_count
    @sc ||= self.columns.inject(0) {|max,column| column.screen_rows.size > max ? column.screen_rows.size : max}
  end
end
