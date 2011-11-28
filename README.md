## Command Line Reporter

This gem provides an simple way to add RSpec like formatting of the output of your ruby scripts.  It
eliminates the need to litter your code with *puts* statements instead providing a cleaner, more
ruby like way of reporting progress to the user throught the command line interface.

### Installation

It is up on rubygems.org so add it to your bundle or do it the old fashioned way:

```bash
gem install command_line_reporter
```

### Usage

The gem provides a mixin that can be included in your scripts.

```ruby
include CommandLineReporter
```

#### Standard Methods

There are several methods the mixin provides that do not depend on the formatter used:

1. _report(hash) {block}_
  * The first argument is a hash that defines the options for the method. See the details in the
    formatter section for allowed values.
  * The second argument is a block of ruby code that you want executed within the context of the
    reporter.  Any ruby code is allowed.  See the examples that follow in the formatter sections for
    details.
1. _formatter=(string)_
  * Simple string indicating the formatter you want your application to use.  At present the 2
    formatters are:

    2. Progress - indicated by the string '_progress_'
    2. Nested - indicated by the string '_nested_'

    The default is _nested_.

### Progress Formatter

#### Example

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

#### Indicator

The indicator is the string that is displayed in the command line interface that indicates progress.
The default is the dot (.) but any string is allowed.  In fact one can use the erase character to
get crafty with displaying percent complete in place.

#### Instance Methods

* _indicator(string)_ - This overrides the default value of the dot (.) being used for all calls to
   the report method.

```ruby
formatter.indicator('*')
```

* _progress(string)_ - Call this method to invoke the output to the command line interface.  The
   string overrides the indicator for this call only.

```ruby
formatter.progress
formatter.progress("^H^H^H10%")
```

### Nested Formatter

The nested formatter concept is inspired by the documentation formatter in RSpec.  The idea is to be
able to create nested grouping levels of output that are very readable as the code is being
executed.

#### Example

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

#### Instance Methods

* _message_string(string)_ - This defines the string that is displayed as the first part of the
  message to the user. The default value is "_working_".

```ruby
formatter.message_string('working')
```

* _complete_string(string)_ - This defines the string that completes the message to the user for the
  report.  The default value is "_complete_".

```ruby
formatter.complete_string('done')
```

* _indent_size(int)_ - The number of spaces to indent for a single indentation level.  The default
  value is 2 spaces.

```ruby
formatter.indent_size(4)
```

#### Report Options

The following are the allowed values of the options hash argument to the _report_ method:

* _message_ - The string that is displayed as the first part of the message to the user
* _complete_ - The string that completes the message to the user
* _type_ - Define as 'inline' if you want the message and complete strings on the same line
* _indent_size_ - The number of spaces to indent the current level

```ruby
report(:message => 'running', :complete => 'finished', :type => 'inline', :indent_size => 8) do
  # code here
end
```

### To Do

1. Add the progress method to the top level mixin so that there is no need to invoke through the
   formatter.
2. Add a _preface_ and _epilogue_ methods so that beginning and ending aspects of the report may be
   added without using _puts_ and _print_.
