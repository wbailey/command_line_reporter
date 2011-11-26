require 'singleton'

module CommandLineReporter
  class NestedFormatter
    include Singleton

    attr_accessor :indent_size, :complete_string, :message_string

    def format(options, block)
      raise ArgumentError unless (options.keys - [:message, :type, :complete, :indent_size]).empty?

      indent_level :incr

      padding = ' ' * @indent_level * (options[:indent_size] || self.indent_size)

      message_str = padding + (options[:message] || self.message_string)
      complete_str = options[:complete] || self.complete_string

      if options[:type] == 'inline'
        print "#{message_str}..."
      else
        puts message_str
        complete_str = padding + complete_str
      end

      block.call

      puts complete_str

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
