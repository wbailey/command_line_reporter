require 'row'
require 'options_validator'

class Table
  include OptionsValidator

  VALID_OPTIONS = [:border]
  attr_accessor :rows, *VALID_OPTIONS

  def initialize(options = {})
    self.validate_options(options, *VALID_OPTIONS)

    self.border = options[:border] || false

    @rows = []
  end

  def add(row)
    # Inheritance from the table
    row.border = self.border

    # Inherit properties from the first row
    if self.rows[0]
      row.columns.each_with_index do |c,i|
        c.align = self.rows[0].columns[i].align
        c.padding = self.rows[0].columns[i].padding
        c.width = self.rows[0].columns[i].width
        c.size = c.width - 2 * c.padding
      end
    end

    self.rows << row
  end

  def to_s
    return if self.rows.size == 0 # we got here with nothing to print to the screen

    puts self.rows[0].separator if self.border
    self.rows.each do |row|
      row.to_s
      puts self.rows[0].separator if self.border
    end
  end
end
