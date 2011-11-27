# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "autotest-growl/version"

Gem::Specification.new do |s|
  s.name        = "autotest-growl"
  s.version     = Autotest::Growl::VERSION
  s.platform    = Gem::Platform::RUBY
  s.authors     = ["Sven Schwyn"]
  s.email       = ["ruby@bitcetera.com"]
  s.homepage    = "http://www.bitcetera.com/products/autotest-growl"
  s.summary     = %q{Growl notification support for autotest}
  s.description = %q{This gem aims to improve support for Growl notifications by autotest.}

  s.rubyforge_project = "autotest-growl"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]

  s.post_install_message = "\e[1;32m\n" + ('-' * 79) + "\n\n" + File.read('PostInstall.txt') + "\n" + ('-' * 79) + "\n\e[0m"
  s.add_development_dependency "rake"
  s.add_development_dependency "rspec"
  s.add_development_dependency "ZenTest"
end
