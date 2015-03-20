require 'singleton'
require 'ansi'

module CommandLineReporter
  class ProgressFormatter
    include Singleton
    include OptionsValidator

    VALID_OPTIONS = [:indicator, :color, :color_code, :bold]
    attr_accessor *VALID_OPTIONS

    def format(options, block)
      self.validate_options(options, *VALID_OPTIONS)

      self.indicator = options[:indicator] if options[:indicator]
      self.color = options[:color]
      self.color_code = options[:color_code]
      self.bold = options[:bold] || false

      block.call

      puts
    end

    def progress(override = nil)
      str = override || self.indicator

      str = ANSI.public_send(color) { str } if self.color
      str = ANSI::Code.rgb(color_code) { str } if self.color_code
      str = ANSI.bold { str } if self.bold

      print str
    end

    def indicator
      @indicator ||= '.'
    end
  end
end
