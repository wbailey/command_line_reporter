require 'stringio'

def capture_stdout
  $stdout = StringIO.new
  $stdin = StringIO.new("y\n")
  yield
  $stdout.string.strip
ensure
  $stdout = STDOUT
  $stdin = STDIN
end
