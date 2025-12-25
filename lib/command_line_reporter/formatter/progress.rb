require 'singleton'
require 'colorize'

module CommandLineReporter
  class ProgressFormatter
    include Singleton
    include OptionsValidator

    VALID_OPTIONS = %i[indicator color bold].freeze
    attr_accessor(*VALID_OPTIONS)

    def format(options, block)
      validate_options(options, *VALID_OPTIONS)

      self.indicator = options[:indicator] if options[:indicator]
      self.color = options[:color]
      self.bold = options[:bold] || false

      block.call

      puts
    end

    def progress(override = nil)
      str = override || indicator

      str = str.send(color) if color
      str = str.send('bold') if bold

      print str
    end

    def indicator
      @indicator ||= '.'
    end
  end
end
