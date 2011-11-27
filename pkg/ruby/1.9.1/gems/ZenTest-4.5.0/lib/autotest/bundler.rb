##
# Prefix all test runs with `bundle exec` so the runs use the bundled
# environment.

module Autotest::Bundler
  Autotest.add_hook :initialize do |at|
    at.prefix = "bundle exec "
    false
  end
end
