## Command Line Reporter

This gem provides an simple way to add RSpec like formatting of the output of your ruby scripts.  It
eliminates the need to litter your code with *puts* statements instead providing a cleaner, more
ruby like way of reporting progress to the user throught the command line interface.

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

### Example

```ruby
require 'command_line_reporter'

class Example
  include CommandLineReporter

  def initialize
    self.formatter = 'progress'
  end

  def run
    x = 0

    report do
      10.times do
        x += 1
        formatter.progress

        10.times do
          x += 1
          formatter.progress
        end
      end
    end
  end
end

Example.new.run
```

#### Formatters

1. Progress
1. Nested

### Progress Formatter

Using this formatter is very easy and the output is the plain old dot.  For a detailed example of
the usage check out the examples directory
