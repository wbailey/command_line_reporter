require 'row'
require 'options_validator'

class Table
  include OptionsValidator

  VALID_OPTIONS = [:border]
  attr_accessor :rows, :widths, *VALID_OPTIONS

  def initialize(options = {})
    self.validate_options(options, *VALID_OPTIONS)

    self.border = options[:border] || false

    @rows = []
  end

  def add(row)
    row.border = self.border

    if self.rows[0]
      # Recalculate the column to ensure all the widths and sizes align with the first row
      row.columns.each_with_index do |c,i|
        c.width = self.widths[i]
        c.size = self.widths[i] - 2 * c.padding
      end
    else
      self.widths = row.columns.map(&:width)
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
