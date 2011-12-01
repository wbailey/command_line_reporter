require 'stringio'

def capture_stdout
  $stdout = StringIO.new
  yield
ensure
  $stdout = STDOUT
end
