require 'spec_helper'
require 'kata/base'

module Kata
  module Base
    describe "DSL" do
      before :each do
        @summary = 'sample summary'
        @display_summary = "#{@summary} Kata"
      end

      describe "#kata" do
        it "is defined" do
          capture_stdout do
            lambda {
              kata @summary
            }.should_not raise_exception
          end
        end

        it "accepts block" do
          capture_stdout do
            lambda {
              kata @summary do
              end
            }.should_not raise_exception
          end
        end

        it "displays the summary" do
          output = capture_stdout do
            lambda {
              kata @summary
            }.should_not raise_exception
          end

          output.should have_summary @display_summary
        end

        it "displays the summary with block" do
          output = capture_stdout do
            lambda {
              kata @summary do
              end
            }.should_not raise_exception
          end

          output.should have_summary @display_summary
        end
      end

      describe "#requirement" do
        before :each do
          @requirement = "Create a simple string calculator with a method add that takes a string argument"
        end

        it "is defined" do
          capture_stdout do
            lambda {
              kata @summary do
                requirement @requirement
              end
            }.should_not raise_exception
          end
        end

        it "accepts block" do
          capture_stdout do
            lambda {
              kata @summary do
                requirement @requirement do
                end
              end
            }.should_not raise_exception
          end
        end

        it "displays the summary" do
          output = capture_stdout do
            lambda {
              kata @summary do
                requirement @requirement
              end
            }.should_not raise_exception
          end

          output.should have_requirement @display_summary, @requirement
        end

        it "displays the summary with block" do
          output = capture_stdout do
            lambda {
              kata @summary do
                requirement @requirement do
                end
              end
            }.should_not raise_exception
          end

          output.should have_requirement @display_summary, @requirement
        end
      end

      describe "#example" do
        before :each do
          @requirement = "Create a simple string calculator with a method add that takes a string argument"
          @examples = [
            %q{The string can contain 0, 1, 2 numbers for example "", "1", "1,2"},
            "The method will return the sum of the digits",
            "Then empty string will return 0",
          ]
        end

        it "are displayed" do
          capture_stdout do
            lambda {
              kata @summary do
                requirement @requirement do
                  Kata::example @examples[0]
                end
              end
            }.should_not raise_exception
          end
        end

        it "are displayed with prompt" do
          output = capture_stdout do
            lambda {
              kata @summary do
                requirement @requirement do
                  Kata::example @examples[0]
                  Kata::example @examples[1]
                  Kata::example @examples[2]
                end
              end
            }.should_not raise_exception
          end

          output.should have_examples @display_summary, @requirement, @examples
        end
      end
    end
  end
end
