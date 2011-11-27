module Autotest::Preload
  def self.glob
    @glob
  end

  def self.glob= o
    @glob = o
  end

  self.glob = "test/test_helper.rb"

  Autotest.add_hook :post_initialize do |at, *args|
    at.add_sigquit_handler

    warn "pre-loading initializers"
    t0 = Time.now
    Dir[self.glob].each do |path|
      require path
    end
    warn "done pre-loading initializers in %.2f seconds" % [Time.now - t0]

    false
  end
end

class Autotest
  alias :old_run_tests :run_tests

  def run_tests
    hook :run_command

    new_mtime = self.find_files_to_test
    return unless new_mtime
    self.last_mtime = new_mtime

    begin
      # TODO: deal with unit_diff and partial test runs later
      original_argv = ARGV.dup
      ARGV.clear

      @child = fork do
        trap "QUIT", "DEFAULT"
        trap "INT", "DEFAULT"
        files_to_test.keys.each do |file|
          load file
        end
      end
      Process.wait
    ensure
      @child = nil
      ARGV.replace original_argv
    end

    hook :ran_command
  end
end
