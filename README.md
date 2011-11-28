## Command Line Reporter

This gem provides an simple way to add RSpec like formatting of the output of your ruby scripts.  It
eliminates the need to litter your code with *puts* statements instead providing a cleaner, more
ruby like way of reporting progress to the user throught the command line interface.

### Installation

```bash
gem install command_line_reporter
```

### Usage

The gem provides a mixin that can be included in your scripts.

```ruby
include CommandLineReporter
```

#### Methods

There are several methods the mixin provides:

1. _report(hash) {block}_
  * The first argument is a hash that defines the options for the method. See the details in the
    formatter section for allowed values.
  * The second argument is a block of ruby code that you want executed within the context of the
    reporter.  Any ruby code is allowed.  See the examples section for details.
1. _formatter=(string)_
  * Simple string indicating the formatter you want your application to use.  The default is
    _nested_
1. _progress(string)_
  * This method is supported by the Progress formatter.

### Progress Formatter

```ruby
require 'command_line_reporter'

class Example
  include CommandLineReporter

  def initialize
    formatter = 'progress'
  end

  def run
    x = 0
    report do
      10.times do
        x += 1
        formatter.progress
      end
    end
  end
end

Example.new.run
```

This simply produces 10 dots (.) in succession:

```bash
[~/scratch]$ ruby example.rb
..........
```

### Nested Formatter

This certainly can be accomplished quite easily with _print_ and _puts_ but the declaritive nature
of the syntax clearly indicates the intention.

A more complex example is using the nested formatter:

```ruby
require 'command_line_reporter'

class Example
  include CommandLineReporter

  def initialize
    self.formatter = 'nested'
  end

  def run
    x,y,z = 0,0,0

    report(:message => 'calculating first expression') do
      x = 2 + 2
      2.times do
        report(:message => 'calculating second expression') do
          y = 10 - x
          10.times do |i|
            report(:message => 'pixelizing', :type => 'inline', :complete => "#{i*10+10}%") do
              z = x + y
            end
          end
        end
      end
    end
  end
end

Example.new.run

```

This produces the more complex output:

```
[~/scratch]$ ruby example.rb
calculating first expression
  calculating second expression
    pixelizing...10%
    pixelizing...20%
    pixelizing...30%
    pixelizing...40%
    pixelizing...50%
    pixelizing...60%
    pixelizing...70%
    pixelizing...80%
    pixelizing...90%
    pixelizing...100%
  complete
  calculating second expression
    pixelizing...10%
    pixelizing...20%
    pixelizing...30%
    pixelizing...40%
    pixelizing...50%
    pixelizing...60%
    pixelizing...70%
    pixelizing...80%
    pixelizing...90%
    pixelizing...100%
  complete
complete
```
