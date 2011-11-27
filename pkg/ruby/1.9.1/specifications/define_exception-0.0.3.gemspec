# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = "define_exception"
  s.version = "0.0.3"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Wes Bailey"]
  s.date = "2010-05-25"
  s.email = "wes@verticalresponse.com"
  s.homepage = "http://github.com/wbailey/define_exception"
  s.rdoc_options = ["--title", "Define Exception Mixin", "--main", "lib/define_exception.rb", "--line-numbers", "--inline-source"]
  s.require_paths = ["lib"]
  s.rubygems_version = "1.8.10"
  s.summary = "A simple way of defining exceptions for use in your ruby classes"

  if s.respond_to? :specification_version then
    s.specification_version = 3

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
    else
    end
  else
  end
end
