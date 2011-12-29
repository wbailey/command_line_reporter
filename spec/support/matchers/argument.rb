RSpec::Matchers.define :accepts_argument do |expected|
  match do
    expected.call.should raise_exception ArgumentError
  end

  # failure_message_for_should do |actual|
  #   'should raise an ArgumentError'
  # end

  # failure_message_for_should_not do |actual|
  #   'should not raise ArgumentError'
  # end

  # description do
  #   'validates options argument'
  # end
end
