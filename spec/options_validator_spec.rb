require 'spec_helper'

describe OptionsValidator do
  subject { Class.new.extend(OptionsValidator) }

  it 'accepts single key options' do
    expect do
      subject.validate_options({ valid: true }, :valid)
    end.to_not raise_error Exception
  end

  it 'rejects invalid option hashes' do
    expect do
      subject.validate_options({ wrong: true }, :valid)
    end.to raise_error ArgumentError
  end

  it 'accepts multi-key options' do
    expect do
      valid = [:valid, :another]
      subject.validate_options({ valid: true, another: true }, *valid)
    end.to_not raise_error Exception
  end
end
