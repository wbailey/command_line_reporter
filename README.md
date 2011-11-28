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

1. _formatter=(string)_
1. _progress(string)_

### Formatters

1. Progress
1. Nested

### Progress Formatter

Using this formatter is very easy and the output is the plain old dot.  For a detailed example of
the usage check out the examples directory
