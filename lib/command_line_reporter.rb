Dir[File.join(File.dirname(__FILE__), '*_formatter.rb')].each {|r| require r}

module CommandLineReporter
  attr_reader :formatter

  def report(options = {}, &block)
    self.formatter = 'nested' if self.formatter.nil?
    self.formatter.format(options, block)
  end

  def formatter=(type = 'nested')
    name = type.capitalize + 'Formatter'
    klass = %W{CommandLineReporter #{name}}.inject(Kernel) {|s,c| s.const_get(c)}

    # Each formatter is a singleton that responds to #instance
    @formatter = klass.instance
  rescue
    raise ArgumentError, 'Invalid formatter specified'
  end
end
