require 'spec_helper'
require 'kata/version'

describe 'kata shell' do
  it "should exit with status 1" do
    system "ruby -I lib bin/kata 1> /dev/null"
    $?.exitstatus.should == 1
  end

  it "should display the version" do
    %x{ruby -I lib bin/kata version}.chomp.should == "kata #{Kata::VERSION}"
  end
  
  it "should run the kata" do
    File.open('test_sample.rb', 'w') do |file|
      file.write <<-EOF
        kata "My Test" do
        end
      EOF
    end

    %x{ruby -I lib bin/kata take test_sample.rb}.chomp.should == 'My Test Kata'

    File.unlink 'test_sample.rb'
  end

  it "should display the usage message" do
    %x{ruby -I lib bin/kata help}.should =~ /NAME\n.*kata - Ruby kata management/
  end
end
