require 'spec_helper'
require 'options_validator'

describe OptionsValidator do
  subject { Class.new.extend(OptionsValidator) }

  it 'accepts single key options' do
    expect {
      subject.validate_options({:valid => true}, :valid)
    }.to_not raise_error
  end

  it 'rejects invalid option hashes' do
    expect {
      subject.validate_options({:wrong => true}, :valid)
    }.to raise_error ArgumentError
  end

  it 'accepts multi-key options' do
    expect {
      valid = [:valid, :another]
      subject.validate_options({:valid => true, :another => true}, *valid)
    }.to_not raise_error
  end
end
