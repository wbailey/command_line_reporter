class Autotest::Result

  ##
  # Analyze test result lines and return the numbers in a hash.
  def initialize(autotest)
    @numbers = {}
    lines = autotest.results.map {|s| s.gsub(/(\e.*?m|\n)/, '') }   # remove escape sequences
    lines.reject! {|line| !line.match(/\d+\s+(example|test|scenario|step)s?/) }   # isolate result numbers
    lines.each do |line|
      prefix = nil
      line.scan(/([1-9]\d*)\s(\w+)/) do |number, kind|
        kind.sub!(/s$/, '')   # singularize
        kind.sub!(/failure/, 'failed')   # homogenize
        if prefix
          @numbers["#{prefix}-#{kind}"] = number.to_i
        else
          @numbers[kind] = number.to_i
          prefix = kind
        end
      end
    end
  end

  ##
  # Determine the testing framework used.
  def framework
    case
      when @numbers['test'] then 'test-unit'
      when @numbers['example'] then 'rspec'
      when @numbers['scenario'] then 'cucumber'
    end
  end

  ##
  # Determine whether a result exists at all.
  def exists?
    !@numbers.empty?
  end

  ##
  # Check whether a specific result is present.
  def has?(kind)
    @numbers.has_key?(kind)
  end

  ##
  # Get a plain result number.
  def [](kind)
    @numbers[kind]
  end

  ##
  # Get a labelled result number. The prefix is removed and the label pluralized if necessary.
  def get(kind)
    "#{@numbers[kind]} #{kind.sub(/^.*-/, '')}#{'s' if @numbers[kind] != 1 && !kind.match(/(ed|ing)$/)}" if @numbers[kind]
  end

  ##
  # Get the fatal error if any.
  def fatal_error
    
  end

end
