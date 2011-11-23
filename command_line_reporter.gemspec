$: << File.join(__FILE__, '..', 'lib')

require 'date'
require 'command_line_reporter/version'

Gem::Specification.new do |gem|
  gem.name    = 'command_line_reporter'
  gem.version = command_line_reporter::VERSION
  gem.date    = Date.today.to_s

  gem.summary = 'A tool for providing interactive command line applications'
  gem.description = 'This gem makes it easy to provide a report while your ruby script is executing'

  gem.authors  = %w/Wes Bailey/
  gem.email    = 'baywes@gmail.com'
  gem.homepage = 'http://github.com/wbailey/command_line_reporter'

  gem.files = Dir['lib/**/*', 'README*', 'LICENSE*'] & `git ls-files -z`.split("\0")
  gem.test_files = Dir['spec/**/*'] & `git ls-files -z`.split("\0")

  gem.add_development_dependency "bundler", ">= 1.0.0"
end

