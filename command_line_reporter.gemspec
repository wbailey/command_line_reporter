$LOAD_PATH << File.expand_path(File.join('..', 'lib'), __FILE__)

require 'date'
require 'command_line_reporter/version'

Gem::Specification.new do |gem|
  gem.name    = 'command_line_reporter'
  gem.version = CommandLineReporter::VERSION
  gem.summary = 'A tool for providing interactive command line applications'
  gem.description = 'This gem makes it easy to provide a report while your ruby script is executing'

  gem.authors  = %w[Wes Bailey]
  gem.email    = 'baywes@gmail.com'
  gem.homepage = 'https://github.com/wbailey/command_line_reporter'
  gem.license = 'MIT'
  gem.required_ruby_version = '>= 3.4.0'
  gem.metadata['rubygems_mfa_required'] = 'true'

  gem.files = Dir['examples/**/*', 'lib/**/*', 'README*', 'LICENSE*'] & `git ls-files -z`.split("\0")

  gem.add_dependency 'colorize', '~> 1.1'
end
