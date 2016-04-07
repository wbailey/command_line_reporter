RSpec::Matchers.define :accepts_argument do |expected|
  match do
    expected.call.should raise_exception ArgumentError
  end
end
