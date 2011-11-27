module Autotest::RCov
  @@command, @@options = "rcov", nil

  def self.command= o
    @@command = o
  end

  def self.pattern= o
    warn "RCov.pattern= no longer has any functionality. please remove."
  end

  def self.options= o
    @@options = o
  end

  Autotest.add_hook :all_good do |at|
    options = @@options ? "RCOVOPTS=\"#{@@options}\"" : ""
    system "rake #{@@command} #{options}"
    false
  end

  Autotest.add_hook :initialize do |at|
    at.add_exception 'coverage'
    at.add_exception 'coverage.info'
    false
  end
end
