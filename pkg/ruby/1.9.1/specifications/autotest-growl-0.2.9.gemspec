# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = "autotest-growl"
  s.version = "0.2.9"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Sven Schwyn"]
  s.date = "2010-12-08"
  s.description = "This gem aims to improve support for Growl notifications by autotest."
  s.email = ["ruby@bitcetera.com"]
  s.homepage = "http://www.bitcetera.com/products/autotest-growl"
  s.post_install_message = "\e[1;32m\n-------------------------------------------------------------------------------\n\nIn order to use autotest-growl, install either the comprehensive \nZenTest gem or the lightweight autotest-standalone gem and then add the \nfollowing line to your ~/.autotest file:\n\nrequire 'autotest/growl'\n\nMake sure the notification service installed on your computer:\n\nhttp://growl.info (Growl for Mac OS X)\nhttp://growlforwindows.com (Growl for Windows)\nhttp://www.galago-project.org (libnotify for Linux)\n\nIf Growl notifications are not always displayed, take a look at the README\nfor assistance.\n\nFor more information, feedback and bug submissions, please visit:\n\nhttp://www.bitcetera.com/products/autotest-growl\n\nIf you like this gem, please consider to recommend me on Working with\nRails, thank you!\n\nhttp://workingwithrails.com/recommendation/new/person/11706-sven-schwyn\n\n-------------------------------------------------------------------------------\n\e[0m"
  s.require_paths = ["lib"]
  s.rubyforge_project = "autotest-growl"
  s.rubygems_version = "1.8.10"
  s.summary = "Growl notification support for autotest"

  if s.respond_to? :specification_version then
    s.specification_version = 3

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_development_dependency(%q<rake>, [">= 0"])
      s.add_development_dependency(%q<rspec>, [">= 0"])
      s.add_development_dependency(%q<ZenTest>, [">= 0"])
    else
      s.add_dependency(%q<rake>, [">= 0"])
      s.add_dependency(%q<rspec>, [">= 0"])
      s.add_dependency(%q<ZenTest>, [">= 0"])
    end
  else
    s.add_dependency(%q<rake>, [">= 0"])
    s.add_dependency(%q<rspec>, [">= 0"])
    s.add_dependency(%q<ZenTest>, [">= 0"])
  end
end
