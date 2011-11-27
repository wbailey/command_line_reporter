##
# Run autotest with isolate support.

module Autotest::Isolate
  @@dir = "tmp/isolate/#{Gem.ruby_engine}-#{RbConfig::CONFIG['ruby_version']}"

  def self.dir= o
    @@dir = o
  end

  Autotest.add_hook :initialize do |at|
    ENV["GEM_PATH"] = @@dir
    ENV["PATH"]    += ":#{@@dir}/bin"

    Gem.clear_paths
    false
  end
end
