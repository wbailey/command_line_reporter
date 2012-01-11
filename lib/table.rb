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
    row.border = self.border
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
