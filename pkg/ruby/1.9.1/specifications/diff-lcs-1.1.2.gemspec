# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = "diff-lcs"
  s.version = "1.1.2"

  s.required_rubygems_version = nil if s.respond_to? :required_rubygems_version=
  s.autorequire = "diff/lcs"
  s.cert_chain = nil
  s.date = "2004-10-20"
  s.description = "Diff::LCS is a port of Algorithm::Diff that uses the McIlroy-Hunt longest common subsequence (LCS) algorithm to compute intelligent differences between two sequenced enumerable containers. The implementation is based on Mario I. Wolczko's Smalltalk version (1.2, 1993) and Ned Konz's Perl version (Algorithm::Diff)."
  s.email = "diff-lcs@halostatue.ca"
  s.executables = ["ldiff", "htmldiff"]
  s.extra_rdoc_files = ["README", "ChangeLog", "Install"]
  s.files = ["bin/ldiff", "bin/htmldiff", "README", "ChangeLog", "Install"]
  s.homepage = "http://rubyforge.org/projects/ruwiki/"
  s.rdoc_options = ["--title", "Diff::LCS -- A Diff Algorithm", "--main", "README", "--line-numbers"]
  s.require_paths = ["lib"]
  s.required_ruby_version = Gem::Requirement.new(">= 1.8.1")
  s.rubyforge_project = "ruwiki"
  s.rubygems_version = "1.8.10"
  s.summary = "Provides a list of changes that represent the difference between two sequenced collections."

  if s.respond_to? :specification_version then
    s.specification_version = 1

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
    else
    end
  else
  end
end
