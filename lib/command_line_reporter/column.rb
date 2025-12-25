require 'colorize'

module CommandLineReporter
  class Column
    include OptionsValidator

    VALID_OPTIONS = %i[width padding align color bold underline reversed span wrap].freeze
    attr_accessor :text, *VALID_OPTIONS

    def initialize(text = nil, options = {})
      validate_options(options, *VALID_OPTIONS)
      assign_alignment_defaults(options)
      assign_color_defaults(options)

      self.text = text.to_s

      self.wrap = options.fetch(:wrap, :character).to_s
      raise(ArgumentError, ":wrap must be word or character (got #{options[:wrap].inspect})") unless %w[word character].include?(wrap)
    end

    def size
      width - (2 * padding) + (3 * (span - 1))
    end

    def required_width
      text.to_s.size + (2 * padding)
    end

    def screen_rows
      if text.nil? || text.empty?
        [' ' * width]
      else
        reformat_wrapped(text).map { |line| to_cell(line) }
      end
    end

    private

    # rubocop:disable Metrics/AbcSize, Metrics/MethodLength
    def reformat_wrapped(text)
      lines = []
      text.lines.each do |line|
        line_words = wrap == 'word' ? line.split(/\s+/) : [line]
        line_words.each do |word|
          current_line = lines.last
          if current_line.nil? || current_line.size + word.size >= size
            # word does not fit on current line. Add new line(s) handling the case where current
            # word is longer than line width.
            lines.concat(word.scan(/.{1,#{size}}/))
          else
            # Word fits on current line.
            (current_line << ' ' << word).strip!
          end
        end
        lines << ''
      end
      lines[0..-2]
    end
    # rubocop:enable Metrics/AbcSize, Metrics/MethodLength

    # rubocop:disable Metrics/AbcSize
    def assign_alignment_defaults(options)
      self.span = options[:span] || 1

      self.width = options[:width] || 10
      self.width = Integer(width)
      self.width *= span

      self.align = options[:align] || 'left'

      self.padding = options[:padding] || 0
      self.padding = Integer(padding)
    end
    # rubocop:enable Metrics/AbcSize

    def assign_color_defaults(options)
      self.color = options[:color] || nil
      self.bold = options[:bold] || false
      self.underline = options[:underline] || false
      self.reversed = options[:reversed] || false
    end

    def to_cell(str)
      # NOTE: For making underline and reversed work Change so that based on the
      # unformatted text it determines how much spacing to add left and right
      # then colorize the cell text
      cell = str.empty? ? blank_cell : aligned_cell(str)
      padding_str = ' ' * padding
      padding_str + colorize(cell) + padding_str
    end

    def blank_cell
      ' ' * size
    end

    def aligned_cell(str)
      case align
      when 'left'
        str.ljust(size)
      when 'right'
        str.rjust(size)
      when 'center'
        str.ljust(((size - str.size) / 2.0) + str.size).rjust(size)
      end
    end

    def colorize(str)
      str = str.send(color) if color
      str = str.send('bold') if bold
      str
    end
  end
end
