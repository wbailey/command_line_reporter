require 'singleton'

module CommandLineReporter
  class NullFormatter
    include Singleton

    attr_accessor :indicator, :indent_size, :complete_string, :message_string

    def format(options, block)
    end

    def progress(override = nil)
    end

    def puts(string)
    end
  end
end
