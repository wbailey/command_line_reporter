## Command Line Reporter

This gem provides an simple way to add RSpec like formatting of the output of your ruby scripts.  It
eliminates the need to litter your code with *puts* statements instead providing a cleaner, more
ruby like way of reporting progress to the user throught the command line interface.

With the release of Version 2.0, it is now possible to produce tables with and without borders.  See
the section on *Tables* for more examples.

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

##### Standard Methods

There are several methods the mixin provides that do not depend on the formatter used:

* _header(hash)_ and _footer(hash)_
  * _:title_ - The title text for the section.  _Default: 'Report'_
  * _:width_ - The width in characters for the section.  _Default: 100_
  * _:align_ - 'left'|'right'|'center' align the title text.  _Default: 'left'_
  * _:spacing_ - Number of vertical lines to leave as spacing after|before the header|footer.
    _Default: 1_
  * _:timestamp_ - Include a line indicating the timestamp below|above the header|footer text.
    Either true|false.  _Default: false_
  * _:rule_ - true|false indicates whether to include a horizontal rule below|above the
    header|footer.  _Default: false_
* _report(hash) {block}_
  * The first argument is a hash that defines the options for the method. See the details in the
    formatter section for allowed values.
  * The second argument is a block of ruby code that you want executed within the context of the
    reporter.  Any ruby code is allowed.  See the examples that follow in the formatter sections for
    details.
* _formatter=(string)_
  * Factory method indicating the formatter you want your application to use.  At present the 2
    formatters are (_Default: 'nested'_):
  * 'progress' - Use the progress formatter
  * 'nested' - Use the nested (or documentation) formatter
* _horizontal_rule(hash)_
  * _:char_ - The character used to build the rule.  _Default: '-'_
  * _:width_ - The width in characters of the rule.  _Default: 100_
* _vertical_spacing(int)_
  * Number of blank lines to output.  _Default: 1_
* _datetime(hash)_
  * _:align_ - 'left'|'center'|'right' alignment of the timestamp.  _Default: 'left'_
  * _:width_ - The width of the string in characters.  _Default: 100_
  * _:format_ - Any allowed format from #strftime#.  _Default: %Y-%m-%d %H:%I:%S%p_
* _aligned(string, hash)_
  * _text_ - String to display
  * _:align_ - 'left'|'right'|'center' align the string text.  _Default: 'left'_
  * _:width_ - The width in characters of the string text.  _Default: 100_
* _table(hash) {block}_
  * The first argument is a hash that defines properties of the table.
    * _:border_ - true|false indicates whether to include borders around the table cells
  * The second argument is a block which includes calls the to the _row_ method
* _row {block}_
  * Only argument is a block with calls to _column_ allowed
* _column(string, hash)_
  * _text_ - String to display in the table cell
  * _options_ - The options to define the column
    * :width - defines the width of the column
    * :padding - The number of spaces to put on both the left and right of the text.
    * :align - Allowed values are left|right|center

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

* _:message_ - The string that is displayed as the first part of the message to the user
* _:complete_ - The string that completes the message to the user
* _:type_ - Define as 'inline' if you want the message and complete strings on the same line
* _:indent_size_ - The number of spaces to indent the current level

```ruby
report(:message => 'running', :complete => 'finished', :type => 'inline', :indent_size => 8) do
  # code here
end
```

### Tables

#### No Frills Example

```ruby
require 'command_line_reporter'

class Example
  include CommandLineReporter

  def run
    table do
      row do
        column('Wes Bailey', :width => 20)
        column('1 Appian Way', :width => 30)
        column('Belmont', :width => 15)
      end
      row do
        column('Richard Feynman', :width => 20)
        column('1 Golden Gate', :width => 30)
        column('Quantum Field', :width => 15)
      end
    end
  end
end

Example.new.run
```

This produces the very simple output with 2 rows and 3 columns of data:

```bash
Wes Bailey           1 Appian Way                   Belmont         
Richard Feynman      1 Golden Gate                  Quantum Field   
```

By default the table does not include a border and the data is left aligned in the columns.

#### Borders, Alignment, Padding and Wrapping

Tables have the capability of doing a lot of convenient things that make formatting the data easy.
This fictitious example shows how to use the combination of options on _table_ and _column_ to
achieve desired alignment and effects.

```ruby
require 'command_line_reporter'

class Example
  include CommandLineReporter

  def run
    align = %w/left right center/

    table(:border => true) do
      3.times do
        row do
          i = 0
          3.times do
            i += 10
            column('x' * (1 + rand(49)), :align => align[rand(3)], :width => i, :padding => rand(5))
          end
        end
      end
    end
  end
end
```

This randomly produces a table with a border that has 3 rows and 3 columns.  Each column gets wider
by 10 characters.  The alignment of the column is demonstrated and you can see where some data
elements have padding around them.

```bash
+------------+----------------------+--------------------------------+
| xxxxxxxxxx |    xxxxxxxxxxxxxx    |   xxxxxxxxxxxxxxxxxxxxxxxxxx   | 
|     xxxxxx |       xxxxxxxxx      |   xxxxxx                       | 
+------------+----------------------+--------------------------------+
| xxxxxxxxxx |    xxxxxxxxxxxxxx    |   xxxxxxxxxxxxxxxxxxxxxxxxxx   | 
| xxxxxxxxxx |    xxxxxxxxxxxxxx    |        xxxxxxxxxxxxxxxxx       | 
| xxxxxxxxxx |    xxxxxxxxxxxxxx    |                                | 
| xxxxxxx    |    xxxx              |                                | 
+------------+----------------------+--------------------------------+
| xxxxxxxxxx |         xxxx         |            xxxxxxxxxxxxxxxxxxx | 
| xxxxxx     |                      |                                | 
+------------+----------------------+--------------------------------+
```

In this particular run of the example you see the first row, first column has the data right
aligned.  The second column is center aligned with a padding of 3 characters.  The last column is
left aligned with a padding of 2 characters.  Remember this was all generated randomly to illustrate
the features.

The best feature is wrapping.  If the text you are display in a cell is larger than the width it was
given, it will automatically wrap it for you.  Padding and alignment are preserved.  It also
properly handles the case where the data in one cell causes the wrapping but other cells my not have
the same number of lines to wrap.

### To Do

* Make it so you only have to specify the properties of a column once.  Right now if you do

```ruby
table(:border => true) do
  row do
     column('asdf', :width => 5)
  end
  row do
     column('qwer')
  end
end
```

It will not preserve the definition in the first row, rather it will just use the default width for
a column which gives the undersired result illustrated below:

```bash
+-------+
| asdf  | 
+-------+
| qwer       | 
+-------+
```

* Add the progress method to the top level mixin so that there is no need to invoke through the
  formatter.
