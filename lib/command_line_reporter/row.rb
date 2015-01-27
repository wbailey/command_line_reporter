module CommandLineReporter
  class Row
    include OptionsValidator

    VALID_OPTIONS = [:header, :color, :bold, :encoding]
    attr_accessor :columns, :border, *VALID_OPTIONS

    def initialize(options = {})
      self.validate_options(options, *VALID_OPTIONS)

      self.columns = []
      self.border = false
      self.header = options[:header] || false
      self.color = options[:color]
      self.bold = options[:bold] || false
      self.encoding = options[:encoding] || :unicode
    end

    def add(column)
      if column.color.nil? && self.color
        column.color = self.color
      end

      if self.bold || self.header
        column.bold = true
      end

      self.columns << column
    end

    def output
      screen_count.times do |sr|
        border_char = use_utf8? ? "\u2503" : '|'

        line = (self.border) ? "#{border_char} " : ''

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
            line << ' ' * col.width << ' '
          else
            line << self.columns[mc].screen_rows[sr] << ' '
          end

          if self.border
            line << border_char
            line << ' ' if mc < self.columns.size - 1
          end
        end

        puts line
      end
    end

    private

    def screen_count
      @sc ||= self.columns.inject(0) {|max,column| column.screen_rows.size > max ? column.screen_rows.size : max}
    end

    def use_utf8?
      self.encoding == :unicode && "\u2501" != "u2501"
    end
  end
end
