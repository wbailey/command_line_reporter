require 'singleton'

module CommandLineReporter
  class ProgressFormatter
    include Singleton

    attr_accessor :indicator

    def format(options, block)
      self.indicator = options[:indicator] if options[:indicator]
      block.call
      Kernel.puts
    end

    def progress(override = nil)
      Kernel.print override || self.indicator
    end

    def indicator
      @indicator ||= '.'
    end

    def puts(string)
      Kernel.puts string
    end
  end
end
