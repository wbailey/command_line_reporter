require 'spec_helper'
require 'options_validator'

VALID_OPTIONS = [:valid]

describe OptionsValidator do
  subject { Class.new.extend(OptionsValidator) }

  it 'accepts single key options' do
    expect {
      subject.validate(:valid => true)
    }.to_not raise_error
  end

  it 'rejects invalid option hashes' do
    expect {
      subject.validate(:wrong => true)
    }.to raise_error ArgumentError
  end

  it 'accepts multi-key options' do
    VALID_OPTIONS << :another

    expect {
      subject.validate({:valid => true, :another => true})
    }.to_not raise_error
  end
end
