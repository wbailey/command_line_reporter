# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = "kata"
  s.version = "1.0.9"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Wes", "Bailey"]
  s.date = "2011-10-05"
  s.description = "This DSL provides an easy way for you to write a code kata for pairing exercises or individual testing"
  s.email = "baywes@gmail.com"
  s.executables = ["kata"]
  s.files = ["bin/kata"]
  s.homepage = "http://github.com/wbailey/kata"
  s.require_paths = ["lib"]
  s.rubygems_version = "1.8.10"
  s.summary = "A code kata DSL"

  if s.respond_to? :specification_version then
    s.specification_version = 3

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_development_dependency(%q<bundler>, [">= 1.0.0"])
    else
      s.add_dependency(%q<bundler>, [">= 1.0.0"])
    end
  else
    s.add_dependency(%q<bundler>, [">= 1.0.0"])
  end
end
