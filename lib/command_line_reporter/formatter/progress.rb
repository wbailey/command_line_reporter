require 'singleton'
require 'options_validator'
require 'colored'

module CommandLineReporter
  class ProgressFormatter
    include Singleton
    include OptionsValidator

    VALID_OPTIONS = [:indicator, :color, :bold]
    attr_accessor *VALID_OPTIONS

    def format(options, block)
      self.validate_options(options, *VALID_OPTIONS)

      self.indicator = options[:indicator] if options[:indicator]
      self.color = options[:color]
      self.bold = options[:bold] || false

      block.call

      puts
    end

    def progress(override = nil)
      str = override || self.indicator

      str = str.send(self.color) if self.color
      str = str.send('bold') if self.bold

      print str
    end

    def indicator
      @indicator ||= '.'
    end
  end
end
