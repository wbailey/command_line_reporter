require 'singleton'
require 'ansi'

module CommandLineReporter
  class NestedFormatter
    include Singleton
    include OptionsValidator

    VALID_OPTIONS = [:message, :type, :complete, :indent_size, :color, :color_code, :bold]
    attr_accessor :indent_size, :complete_string, :message_string, :color, :color_code, :bold

    def format(options, block)
      self.validate_options(options, *VALID_OPTIONS)

      indent_level :incr

      padding = ' ' * @indent_level * (options[:indent_size] || self.indent_size)

      message_str = padding + (options[:message] || self.message_string)
      complete_str = options[:complete] || self.complete_string

      if options[:type] == 'inline'
        colorize("#{message_str}...", true, options)
      else
        colorize(message_str, false, options)
        complete_str = padding + complete_str
      end

      block.call

      colorize(complete_str, false, options)

      indent_level :decr
    end

    def message_string
      @message_string ||= 'working'
    end

    def complete_string
      @complete_string ||= 'complete'
    end

    def indent_size
      @indent_size ||= 2
    end

    private

    def colorize(str, inline, options)
      str = ANSI.public_send(options[:color]) { str } if options[:color]
      str = ANSI::Code.rgb(options[:color_code]) { str } if options[:color_code]
      str = ANSI.bold { str } if options[:bold]

      if inline
        print str
      else
        puts str
      end
    end

    def indent_level(value)
      case value
      when :incr
        @indent_level = (@indent_level) ? @indent_level + 1 : 0
      when :decr
        @indent_level -= 1
      end
    end
  end
end
