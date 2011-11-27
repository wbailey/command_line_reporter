require 'find'
require 'rbconfig'

$TESTING = false unless defined? $TESTING

##
# Autotest continuously scans the files in your project for changes
# and runs the appropriate tests.  Test failures are run until they
# have all passed. Then the full test suite is run to ensure that
# nothing else was inadvertantly broken.
#
# If you want Autotest to start over from the top, hit ^C once.  If
# you want Autotest to quit, hit ^C twice.
#
# Rails:
#
# The autotest command will automatically discover a Rails directory
# by looking for config/environment.rb. When Rails is discovered,
# autotest uses RailsAutotest to perform file mappings and other work.
# See RailsAutotest for details.
#
# Plugins:
#
# Plugins are available by creating a .autotest file either in your
# project root or in your home directory. You can then write event
# handlers in the form of:
#
#   Autotest.add_hook hook_name { |autotest| ... }
#
# The available hooks are listed in +ALL_HOOKS+.
#
# See example_dot_autotest.rb for more details.
#
# If a hook returns a true value, it signals to autotest that the hook
# was handled and should not continue executing hooks.
#
# Naming:
#
# Autotest uses a simple naming scheme to figure out how to map
# implementation files to test files following the Test::Unit naming
# scheme.
#
# * Test files must be stored in test/
# * Test files names must start with test_
# * Test class names must start with Test
# * Implementation files must be stored in lib/
# * Implementation files must match up with a test file named
#   test_.*implementation.rb
#
# Strategy:
#
# 1. Find all files and associate them from impl <-> test.
# 2. Run all tests.
# 3. Scan for failures.
# 4. Detect changes in ANY (ruby?. file, rerun all failures + changed files.
# 5. Until 0 defects, goto 3.
# 6. When 0 defects, goto 2.

class Autotest

  RUBY19 = defined? Encoding

  T0 = Time.at 0

  ALL_HOOKS = [ :all_good, :died, :green, :initialize,
                :post_initialize, :interrupt, :quit, :ran_command,
                :red, :reset, :run_command, :updated, :waiting ]

  def self.options
    @@options ||= {}
  end

  def options
    self.class.options
  end

  HOOKS = Hash.new { |h,k| h[k] = [] }
  unless defined? WINDOZE then
    WINDOZE = /mswin|mingw/ =~ RbConfig::CONFIG['host_os']
    SEP = WINDOZE ? '&' : ';'
  end

  @@discoveries = []

  def self.parse_options args = ARGV
    require 'optparse'
    options = {}
    OptionParser.new do |opts|
      opts.banner = <<-BANNER.gsub(/^        /, '')
        Continuous testing for your ruby app.

          Autotest automatically tests code that has changed. It
          assumes the code is in lib, and tests are in tests. Autotest
          uses plugins to control what happens. You configure plugins
          with require statements in the .autotest file in your
          project base directory, and a default configuration for all
          your projects in the .autotest file in your home directory.

        Usage:
            autotest [options]
      BANNER

      opts.on "-f", "--fast-start", "Do not run full tests at start" do
        options[:no_full_after_start] = true
      end

      opts.on("-c", "--no-full-after-failed",
              "Do not run all tests on red->green") do
        options[:no_full_after_failed] = true
      end

      opts.on "-v", "--verbose", "Be annoyingly verbose (debugs .autotest)." do
        options[:verbose] = true
      end

      opts.on "-q", "--quiet", "Be quiet." do
        options[:quiet] = true
      end

      opts.on("-r", "--rc CONF", String, "Override path to config file") do |o|
        options[:rc] = o
      end

      opts.on("-s", "--style STYLE", String,
              "Manually specify test style. (default: autodiscover)") do |style|
        options[:style] = Array(style)
      end

      opts.on("-w", "--warnings", "Turn on ruby warnings") do
        $-w = true
      end

      opts.on "-h", "--help", "Show this." do
        puts opts
        exit 1
      end
    end.parse args

    Autotest.options.merge! options

    options
  end

  ##
  # Calculates the autotest runner to use to run the tests.
  #
  # Can be overridden with --style, otherwise uses ::autodiscover.

  def self.runner
    style = options[:style] || Autotest.autodiscover
    target = Autotest

    unless style.empty? then
      mod = "autotest/#{style.join "_"}"
      puts "loading #{mod}"
      begin
        require mod
      rescue LoadError
        abort "Autotest style #{mod} doesn't seem to exist. Aborting."
      end
      target = Autotest.const_get(style.map {|s| s.capitalize}.join)
    end

    target
  end

  ##
  # Add a proc to the collection of discovery procs. See
  # +autodiscover+.

  def self.add_discovery &proc
    @@discoveries << proc
  end

  ##
  # Automatically find all potential autotest runner styles by
  # searching your loadpath, vendor/plugins, and rubygems for
  # "autotest/discover.rb". If found, that file is loaded and it
  # should register discovery procs with autotest using
  # +add_discovery+. That proc should return one or more strings
  # describing the user's current environment. Those styles are then
  # combined to dynamically invoke an autotest plugin to suite your
  # environment. That plugin should define a subclass of Autotest with
  # a corresponding name.
  #
  # === Process:
  #
  # 1. All autotest/discover.rb files loaded.
  # 2. Those procs determine your styles (eg ["rails", "rspec"]).
  # 3. Require file by sorting styles and joining (eg 'autotest/rails_rspec').
  # 4. Invoke run method on appropriate class (eg Autotest::RailsRspec.run).
  #
  # === Example autotest/discover.rb:
  #
  #   Autotest.add_discovery do
  #     "rails" if File.exist? 'config/environment.rb'
  #   end
  #

  def self.autodiscover
    require 'rubygems'

    # *sigh*
    #
    # This is needed for rspec's hacky discovery mechanism. For some
    # reason rspec2 added generators that create
    # "autotest/discover.rb" right in the project directory instead of
    # keeping it in the rspec gem and properly deciding that the
    # project is an rspec based project or not. See the url for more
    # details:
    #
    # http://rubyforge.org/tracker/?func=detail&atid=1678&aid=28775&group_id=419
    #
    # For the record, the sane way to do it is the bacon way:
    #
    # "Since version 1.0, there is autotest support. You need to tag
    # your test directories (test/ or spec/) by creating an .bacon
    # file there. Autotest then will find it."
    #
    # I'm submitting a counter-patch to rspec to fix stuff properly,
    # but for now I'm stuck with this because their brokenness is
    # documented in multiple books.
    #
    # I'm removing this code once a sane rspec goes out.

    hacky_discovery = Gem.source_index.gems.any? { |n,_| n =~ /^rspec/ }
    $: << '.' if hacky_discovery

    Gem.find_files("autotest/discover").each do |f|
      load f
    end

    # call all discovery procs and determine the style to use
    @@discoveries.map{ |proc| proc.call }.flatten.compact.sort.uniq
  end

  ##
  # Initialize and run the system.

  def self.run
    new.run
  end

  attr_writer :known_files
  attr_accessor(:completed_re,
                :extra_class_map,
                :extra_files,
                :failed_results_re,
                :files_to_test,
                :find_order,
                :interrupted,
                :latest_results,
                :last_mtime,
                :libs,
                :order,
                :output,
                :prefix,
                :results,
                :sleep,
                :tainted,
                :testlib,
                :find_directories,
                :unit_diff,
                :wants_to_quit)

  alias tainted? tainted

  ##
  # Initialize the instance and then load the user's .autotest file, if any.

  def initialize
    # these two are set directly because they're wrapped with
    # add/remove/clear accessor methods
    @exception_list = []
    @test_mappings = []
    @child = nil

    self.completed_re =
      /\d+ tests, \d+ assertions, \d+ failures, \d+ errors(, \d+ skips)?/
    self.extra_class_map   = {}
    self.extra_files       = []
    self.failed_results_re = /^\s+\d+\) (?:Failure|Error):\n(.*?)\((.*?)\)/
    self.files_to_test     = new_hash_of_arrays
    self.find_order        = []
    self.known_files       = nil
    self.libs              = %w[. lib test].join(File::PATH_SEPARATOR)
    self.order             = :random
    self.output            = $stderr
    self.prefix            = nil
    self.sleep             = 1
    self.testlib           = "test/unit"
    self.find_directories  = ['.']
    self.unit_diff         = "unit_diff -u"
    self.latest_results    = nil

    # file in /lib -> run test in /test
    self.add_mapping(/^lib\/.*\.rb$/) do |filename, _|
      possible = File.basename(filename).gsub '_', '_?' # ' stupid emacs
      files_matching %r%^test/.*#{possible}$%
    end

    # file in /test -> run it
    self.add_mapping(/^test.*\/test_.*rb$/) do |filename, _|
      filename
    end

    default_configs = [File.expand_path('~/.autotest'), './.autotest']
    configs = options[:rc] || default_configs

    configs.each do |f|
      load f if File.exist? f
    end
  end

  ##
  # Repeatedly run failed tests, then all tests, then wait for changes
  # and carry on until killed.

  def run
    hook :initialize
    hook :post_initialize

    reset
    add_sigint_handler

    self.last_mtime = Time.now if options[:no_full_after_start]

    loop do
      begin # ^c handler
        get_to_green
        if tainted? and not options[:no_full_after_failed] then
          rerun_all_tests
        else
          hook :all_good
        end
        wait_for_changes
      rescue Interrupt
        break if wants_to_quit
        reset
      end
    end
    hook :quit
  rescue Exception => err
    hook :died, err
  end

  ##
  # Keep running the tests after a change, until all pass.

  def get_to_green
    begin
      run_tests
      wait_for_changes unless all_good
    end until all_good
  end

  ##
  # Look for files to test then run the tests and handle the results.

  def run_tests
    hook :run_command

    new_mtime = self.find_files_to_test
    return unless new_mtime
    self.last_mtime = new_mtime

    cmd = self.make_test_cmd self.files_to_test
    return if cmd.empty?

    puts cmd unless options[:quiet]

    old_sync = $stdout.sync
    $stdout.sync = true
    self.results = []
    line = []
    begin
      open "| #{cmd}", "r" do |f|
        until f.eof? do
          c = f.getc or break
          if RUBY19 then
            print c
          else
            putc c
          end
          line << c
          if c == ?\n then
            self.results << if RUBY19 then
                              line.join
                            else
                              line.pack "c*"
                            end
            line.clear
          end
        end
      end
    ensure
      $stdout.sync = old_sync
    end
    hook :ran_command
    self.results = self.results.join

    handle_results self.results
  end

  ############################################################
  # Utility Methods, not essential to reading of logic

  ##
  # Installs a sigint handler.

  def add_sigint_handler
    trap 'INT' do
      Process.kill "KILL", @child if @child

      if self.interrupted then
        self.wants_to_quit = true
      else
        unless hook :interrupt then
          puts "Interrupt a second time to quit"
          self.interrupted = true
          Kernel.sleep 1.5
        end
        raise Interrupt, nil # let the run loop catch it
      end
    end
  end

  ##
  # Installs a sigquit handler

  def add_sigquit_handler
    trap 'QUIT' do
      restart
    end
  end

  def restart
    Process.kill "KILL", @child if @child

    cmd = [$0, *ARGV]

    index = $LOAD_PATH.index RbConfig::CONFIG["sitelibdir"]

    if index then
      extra = $LOAD_PATH[0...index]
      cmd = [Gem.ruby, "-I", extra.join(":")] + cmd
    end

    puts cmd.join(" ") if options[:verbose]

    exec(*cmd)
  end

  ##
  # If there are no files left to test (because they've all passed),
  # then all is good.

  def all_good
    files_to_test.empty?
  end

  ##
  # Convert a path in a string, s, into a class name, changing
  # underscores to CamelCase, etc.

  def path_to_classname s
    sep = File::SEPARATOR
    f = s.sub(/^test#{sep}/, '').sub(/\.rb$/, '').split sep
    f = f.map { |path| path.split(/_|(\d+)/).map { |seg| seg.capitalize }.join }
    f = f.map { |path| path =~ /^Test/ ? path : "Test#{path}"  }

    f.join '::'
  end

  ##
  # Returns a hash mapping a file name to the known failures for that
  # file.

  def consolidate_failures failed
    filters = new_hash_of_arrays

    class_map = Hash[*self.find_order.grep(/^test/).map { |f| # TODO: ugly
                       [path_to_classname(f), f]
                     }.flatten]
    class_map.merge! self.extra_class_map

    failed.each do |method, klass|
      if class_map.has_key? klass then
        filters[class_map[klass]] << method
      else
        output.puts "Unable to map class #{klass} to a file"
      end
    end

    filters
  end

  ##
  # Find the files to process, ignoring temporary files, source
  # configuration management files, etc., and return a Hash mapping
  # filename to modification time.

  def find_files
    result = {}
    targets = self.find_directories + self.extra_files
    self.find_order.clear

    targets.each do |target|
      order = []
      Find.find target do |f|
        Find.prune if f =~ self.exceptions

        next if test ?d, f
        next if f =~ /(swp|~|rej|orig)$/ # temporary/patch files
        next if f =~ /\/\.?#/            # Emacs autosave/cvs merge files

        filename = f.sub(/^\.\//, '')

        result[filename] = File.stat(filename).mtime rescue next
        order << filename
      end
      self.find_order.push(*order.sort)
    end

    result
  end

  ##
  # Find the files which have been modified, update the recorded
  # timestamps, and use this to update the files to test. Returns
  # the latest mtime of the files modified or nil when nothing was
  # modified.

  def find_files_to_test files = find_files
    updated = files.select { |filename, mtime| self.last_mtime < mtime }

    # nothing to update or initially run
    unless updated.empty? || self.last_mtime.to_i == 0 then
      p updated if options[:verbose]

      hook :updated, updated
    end

    updated.map { |f,m| test_files_for f }.flatten.uniq.each do |filename|
      self.files_to_test[filename] # creates key with default value
    end

    if updated.empty? then
      nil
    else
      files.values.max
    end
  end

  ##
  # Check results for failures, set the "bar" to red or green, and if
  # there are failures record this.

  def handle_results results
    results = results.gsub(/\e\[\d+m/, '') # strip ascii color
    failed = results.scan self.failed_results_re
    completed = results[self.completed_re]

    if completed then
      completed = completed.scan(/(\d+) (\w+)/).map { |v, k| [k, v.to_i] }

      self.latest_results = Hash[*completed.flatten]
      self.files_to_test  = consolidate_failures failed

      color = self.files_to_test.empty? ? :green : :red
      hook color unless $TESTING
    else
      self.latest_results = nil
    end

    self.tainted = true unless self.files_to_test.empty?
  end

  ##
  # Lazy accessor for the known_files hash.

  def known_files
    unless @known_files then
      @known_files = Hash[*find_order.map { |f| [f, true] }.flatten]
    end
    @known_files
  end

  ##
  # Returns the base of the ruby command.

  def ruby_cmd
    "#{prefix}#{ruby} -I#{libs} -rubygems"
  end

  ##
  # Generate the commands to test the supplied files

  def make_test_cmd files_to_test
    cmds = []
    full, partial = reorder(files_to_test).partition { |k,v| v.empty? }

    unless full.empty? then
      classes = full.map {|k,v| k}.flatten.uniq
      classes.unshift testlib
      cmds << "#{ruby_cmd} -e \"%w[#{classes.join ' '}].each { |f| require f }\" | #{unit_diff}"
    end

    partial.each do |klass, methods|
      regexp = Regexp.union(*methods).source
      cmds << "#{ruby_cmd} #{klass} -n \"/^(#{regexp})$/\" | #{unit_diff}"
    end

    cmds.join "#{SEP} "
  end

  def new_hash_of_arrays
    Hash.new { |h,k| h[k] = [] }
  end

  def reorder files_to_test
    case self.order
    when :alpha then
      files_to_test.sort_by { |k,v| k }
    when :reverse then
      files_to_test.sort_by { |k,v| k }.reverse
    when :random then
      max = files_to_test.size
      files_to_test.sort_by { |k,v| rand max }
    when :natural then
      (self.find_order & files_to_test.keys).map { |f| [f, files_to_test[f]] }
    else
      raise "unknown order type: #{self.order.inspect}"
    end
  end

  ##
  # Rerun the tests from cold (reset state)

  def rerun_all_tests
    reset
    run_tests

    hook :all_good if all_good
  end

  ##
  # Clear all state information about test failures and whether
  # interrupts will kill autotest.

  def reset
    self.files_to_test.clear
    self.find_order.clear

    self.interrupted   = false
    self.known_files   = nil
    self.last_mtime    = T0
    self.tainted       = false
    self.wants_to_quit = false

    hook :reset
  end

  ##
  # Determine and return the path of the ruby executable.

  def ruby
    ruby = ENV['RUBY']
    ruby ||= File.join(RbConfig::CONFIG['bindir'],
                       RbConfig::CONFIG['ruby_install_name'])

    ruby.gsub! File::SEPARATOR, File::ALT_SEPARATOR if File::ALT_SEPARATOR

    return ruby
  end

  ##
  # Return the name of the file with the tests for filename by finding
  # a +test_mapping+ that matches the file and executing the mapping's
  # proc.

  def test_files_for filename
    result = @test_mappings.find { |file_re, ignored| filename =~ file_re }

    p :test_file_for => [filename, result.first] if result and $DEBUG

    result = result.nil? ? [] : [result.last.call(filename, $~)].flatten

    output.puts "No tests matched #{filename}" if
      (options[:verbose] or $TESTING) and result.empty?

    result.sort.uniq.select { |f| known_files[f] }
  end

  ##
  # Sleep then look for files to test, until there are some.

  def wait_for_changes
    hook :waiting
    Kernel.sleep self.sleep until find_files_to_test
  end

  ############################################################
  # File Mappings:

  ##
  # Returns all known files in the codebase matching +regexp+.

  def files_matching regexp
    self.find_order.select { |k| k =~ regexp }
  end

  ##
  # Adds a file mapping, optionally prepending the mapping to the
  # front of the list if +prepend+ is true. +regexp+ should match a
  # file path in the codebase. +proc+ is passed a matched filename and
  # Regexp.last_match. +proc+ should return an array of tests to run.
  #
  # For example, if test_helper.rb is modified, rerun all tests:
  #
  #   at.add_mapping(/test_helper.rb/) do |f, _|
  #     at.files_matching(/^test.*rb$/)
  #   end

  def add_mapping regexp, prepend = false, &proc
    if prepend then
      @test_mappings.unshift [regexp, proc]
    else
      @test_mappings.push [regexp, proc]
    end
    nil
  end

  ##
  # Removed a file mapping matching +regexp+.

  def remove_mapping regexp
    @test_mappings.delete_if do |k,v|
      k == regexp
    end
    nil
  end

  ##
  # Clears all file mappings. This is DANGEROUS as it entirely
  # disables autotest. You must add at least one file mapping that
  # does a good job of rerunning appropriate tests.

  def clear_mappings
    @test_mappings.clear
    nil
  end

  ############################################################
  # Exceptions:

  ##
  # Adds +regexp+ to the list of exceptions for find_file. This must
  # be called _before_ the exceptions are compiled.

  def add_exception regexp
    raise "exceptions already compiled" if defined? @exceptions

    @exception_list << regexp
    nil
  end

  ##
  # Removes +regexp+ to the list of exceptions for find_file. This
  # must be called _before_ the exceptions are compiled.

  def remove_exception regexp
    raise "exceptions already compiled" if defined? @exceptions
    @exception_list.delete regexp
    nil
  end

  ##
  # Clears the list of exceptions for find_file. This must be called
  # _before_ the exceptions are compiled.

  def clear_exceptions
    raise "exceptions already compiled" if defined? @exceptions
    @exception_list.clear
    nil
  end

  ##
  # Return a compiled regexp of exceptions for find_files or nil if no
  # filtering should take place. This regexp is generated from
  # +exception_list+.

  def exceptions
    unless defined? @exceptions then
      @exceptions = if @exception_list.empty? then
                      nil
                    else
                      Regexp.union(*@exception_list)
                    end
    end

    @exceptions
  end

  ############################################################
  # Hooks:

  ##
  # Call the event hook named +name+, passing in optional args
  # depending on the hook itself.
  #
  # Returns false if no hook handled the event.
  #
  # === Hook Writers!
  #
  # This executes all registered hooks <em>until one returns truthy</em>.
  # Pay attention to the return value of your block!

  def hook name, *args
    deprecated = {
      # none currently
    }

    if deprecated[name] and not HOOKS[name].empty? then
      warn "hook #{name} has been deprecated, use #{deprecated[name]}"
    end

    HOOKS[name].any? { |plugin| plugin[self, *args] }
  end

  ##
  # Add the supplied block to the available hooks, with the given
  # name.

  def self.add_hook name, &block
    HOOKS[name] << block
  end

  add_hook :died do |at, args|
    err = *args
    warn "Unhandled exception: #{err}"
    warn err.backtrace.join("\n  ")
    warn "Quitting"
  end
end
