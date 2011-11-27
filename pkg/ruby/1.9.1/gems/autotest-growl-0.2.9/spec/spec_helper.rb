$LOAD_PATH.unshift(File.dirname(__FILE__))
$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))
require 'autotest/growl'
require 'rspec'
require 'rspec/autorun'

RSpec.configure do |config|
end

module Autotest::Growl
  def self.growl(title, message, icon, priority=0, stick="")
    icon
  end
end