require 'spec_helper'
require 'row'

describe Row do
  context 'Creation' do
    it 'defaults options hash' do
      expect {
        Row.new
      }.to_not raise_error
    end
  end
end
