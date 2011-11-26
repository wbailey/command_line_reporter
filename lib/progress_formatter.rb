require 'singleton'

module CommandLineReporter
  class ProgressFormatter
    include Singleton

    attr_accessor :indicator

    def format(options, block)
      self.indicator = options[:indicator] if options[:indicator]
      block.call
      puts
    end

    def progress(override = nil)
      print override || self.indicator
    end

    def indicator
      @indicator ||= '.'
    end
  end
end
