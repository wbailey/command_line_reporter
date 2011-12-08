class Table
  attr_accessor :width, :padding, :border

  def initialize(options = {})
    raise ArgumentError unless (options.keys - [:width, :border, :padding]).empty?

    self.width = (options[:width] || 100).to_i
    self.border = options[:border] || false
    self.padding = (options[:padding] || 1).to_i

    raise ArgumentError unless self.width > 0 && self.padding > 0
  end
end
