## Command Line Reporter [![Build Status](https://travis-ci.org/wbailey/command_line_reporter.png)](https://travis-ci.org/wbailey/command_line_reporter)  [![Code Climate](https://codeclimate.com/github/wbailey/command_line_reporter.png)](https://codeclimate.com/github/wbailey/command_line_reporter) [![Gem Version](https://badge.fury.io/rb/command_line_reporter.png)](http://badge.fury.io/rb/command_line_reporter)

This gem provides a DSL that makes it easy to write reports of various types in ruby.  It eliminates
the need to litter your source with *puts* statements instead providing a more readable, expressive
interface to your application.  Some of the best features include:

* Formatters that automatically indicate progress
* Table syntax similar to HTML that makes it trivial to format your data in rows and columns
* Easily created headers and footers for your report
* Output suppression that makes it easy for your script to support a _quiet_ flag
* Capture report output as a string

The latest release uses unicode drawing characters for the table, colors allowing you to distinguish
data in new ways including bold if your terminal supports it.  Here is an example of output you can
generate easily with "the reporter":

![Screenshot](http://i.imgur.com/5izCf.png)

### Installation

It is up on rubygems.org so add it to your bundle in the Gemfile

```bash
gem 'command_line_reporter', '>=3.0'
```

or do it the old fashioned way:

```bash
gem install command_line_reporter
```

### Usage

The gem provides a mixin that can be included in your scripts.

```ruby
require 'command_line_reporter'

class MyReport
  include CommandLineReporter
  ...
end
```

### [Wiki](https://github.com/wbailey/command_line_reporter/wiki)

The [Wiki](https://github.com/wbailey/command_line_reporter/wiki) has all of the documentation
necessary for getting you started.

### API Reference

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
  * _:color_ - The color to use for the terminal output i.e. 'red' or 'blue' or 'green'
  * _:bold_ - true|false to boldface the font
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
  * _:color_ - The color to use for the terminal output i.e. 'red' or 'blue' or 'green'
  * _:bold_ - true|false to boldface the font
* _vertical_spacing(int)_
  * Number of blank lines to output.  _Default: 1_
* _datetime(hash)_
  * _:align_ - 'left'|'center'|'right' alignment of the timestamp.  _Default: 'left'_
  * _:width_ - The width of the string in characters.  _Default: 100_
  * _:format_ - Any allowed format from #strftime#.  _Default: %Y-%m-%d %H:%I:%S%p_
  * _:color_ - The color to use for the terminal output i.e. 'red' or 'blue' or 'green'
  * _:bold_ - true|false to boldface the font
* _aligned(string, hash)_
  * _text_ - String to display
  * _:align_ - 'left'|'right'|'center' align the string text.  _Default: 'left'_
  * _:width_ - The width in characters of the string text.  _Default: 100_
  * _:color_ - The color to use for the terminal output i.e. 'red' or 'blue' or 'green'
  * _:bold_ - true|false to boldface the font
* _table(hash) {block}_
  * The first argument is a hash that defines properties of the table.
    * _:border_ - true|false indicates whether to include borders around the table cells
    * _:encoding_ - :ascii or :unicode (default unicode)
  * The second argument is a block which includes calls the to the _row_ method
* _row {block}_
  * _:header_ - Set to true to indicate if this is a header row in the table.
  * _:color_ - The color to use for the terminal output i.e. 'red' or 'blue' or 'green'
  * _:bold_ - true|false to boldface the font
* _column(string, hash)_
  * _text_ - String to display in the table cell
  * _options_ - The options to define the column
    * :width - defines the width of the column
    * :padding - The number of spaces to put on both the left and right of the text.
    * :align - Allowed values are left|right|center
    * :color - The color to use for the terminal output i.e. 'red' or 'blue' or 'green'
    * :bold - true|false to boldface the font
* _suppress_output_ - Suppresses output stream that goes to STDOUT
* _capture_output_ - Captures all of the output stream to a string and restores output to STDOUT
* _restore_output_ - Restores the output stream to STDOUT

### To Do

* Refactor the table structure to use a formatter that produces the current ascii output
* After the formatter is added to a table then create one for html output
* Add the ability for a column to span across others in a table

### Contributors

* Thanks to [Stefan Frank](https://github.com/mugwump) for raising the issue that he could not
  capture report output in a variable as a string
* Thanks to [Mike Gunderloy](https://github.com/ffmike) for suggesting the need for suppressing
  output and putting together a fantastic pull request and discussion
* Thanks to [Jason Rogers](https://github.com/jacaetevha) and [Peter
  Suschlik](https://github.com/splattael) for their contributions as well on items I missed

### License

Copyright (c) 2011-2013 Wes Bailey

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and
associated documentation files (the "Software"), to deal in the Software without restriction,
including without limitation the rights to use, copy, modify, merge, publish, distribute,
sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial
portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT
NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES
OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN
CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
