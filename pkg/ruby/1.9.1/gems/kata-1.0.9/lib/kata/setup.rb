require 'fileutils'
require 'ostruct'

module Kata
  class Setup
    attr_accessor :kata_name
    attr_reader :repo_name

    def initialize(kata_name = 'kata')
      self.kata_name = kata_name
      self.repo_name = kata_name
    end

    def create_repo
      # Setup from github configuration
      raise Exception, 'Git not installed' unless system 'which git > /dev/null'

      github = OpenStruct.new :url => 'http://github.com/api/v2/json/'

      github_user, shell_user = %x{git config --get github.user}.chomp, ENV['USER']

      github.user = github_user.empty? ? shell_user : github_user

      raise Exception, 'Unable to determine github user' if github.user.empty?

      github.token = %x{git config --get github.token}.chomp

      raise Exception, 'Unable to determine github api token' if github.token.empty?

      user_string = "-u '#{github.user}/token:#{github.token}'"
      repo_params = "-d 'name=#{repo_name}' -d 'description=code+kata+repo'"

      # Create the repo on github
      print 'Creating github repo...'
      raise SystemCallError, 'unable to use curl to create repo on github' unless system <<-EOF
        curl -s #{user_string} #{repo_params} #{github.url}repos/create 2>&1 > /dev/null;
      EOF
      puts 'complete'

      # publish to github

      print 'creating files for repo and initializing...'
      raise SystemCallError, 'unable to publish repo to github' unless system <<-EOF
        cd #{repo_name};
        git init 2>&1 > /dev/null;
        git add README lib/ spec/ 2>&1 > /dev/null;
        git commit -m 'starting kata' 2>&1 > /dev/null;
        git remote add origin git@github.com:#{github.user}/#{repo_name}.git 2>&1 > /dev/null;
        git push origin master 2> /dev/null
      EOF
      puts 'done'
      puts "You can now change directories to #{repo_name} and take your kata"
    end

    def repo_name=(kata_name)
      @repo_name = "#{kata_name.gsub(/( |-)\1?/, '_')}-#{Time.now.strftime('%Y-%m-%d-%H%M%S')}".downcase
    end

    def build_tree
      %W{#{repo_name}/lib #{repo_name}/spec/support/helpers #{repo_name}/spec/support/matchers}.each {|path| FileUtils.mkdir_p path}

      use_kata_name = kata_name.gsub(/( |-)\1?/, '_').downcase
      class_name = kata_name.split(/ |-|_/).map(&:capitalize).join

      # create the README file so github is happy
      File.open(File.join(repo_name, 'README'), 'w') {|f| f.write <<EOF}
Leveling up my ruby awesomeness!
EOF

      # create the base class file
      File.open(File.join(repo_name, 'lib', "#{use_kata_name}.rb"), 'w') {|f| f.write <<EOF}
class #{class_name}
end
EOF
      # create the .rspec file
      File.open(File.join(repo_name, '.rspec'), 'w') {|f| f.write <<EOF}
--color --format d
EOF

      # create the spec_helper.rb file
      File.open(File.join(repo_name, 'spec', 'spec_helper.rb'), 'w') {|f| f.write <<EOF}
$: << '.' << File.join(File.dirname(__FILE__), '..', 'lib')

require 'rspec'

Dir[File.dirname(__FILE__) + "/support/**/*.rb"].each {|f| require f}
EOF

      # create a working spec file for the kata
      File.open(File.join(repo_name, 'spec', "#{use_kata_name}_spec.rb"), 'w') {|f| f.write <<EOF}
require 'spec_helper'
require '#{use_kata_name}'

describe #{class_name} do
  describe "new" do
    it "should instantiate" do
      lambda {
        #{class_name}.new
      }.should_not raise_exception
    end
  end
end
EOF
      # stub out a custom matchers file
      File.open(File.join(repo_name, 'spec', 'support', 'matchers', "#{use_kata_name}.rb"), 'w') {|f| f.write <<EOF}
RSpec::Matchers.define :your_method do |expected|
  match do |your_match|
    #your_match.method_on_object_to_execute == expected
  end
end
EOF
    end
  end
end
