$: << File.dirname( File.join( __FILE__, '..' ) )

require 'rubygems'
require 'define_exception'
require 'spec/test/unit'

include DefineException

@@message = 'This is the default @@message'

describe "Define Exception" do
  it "should enable a class to define a custom exception using a string" do

    class TestDefineException
      define_exception 'TestException', @@message

      def test
        raise TestException
      end
    end

    tde = TestDefineException.new

    lambda {
      tde.test
    }.should raise_error( TestDefineException::TestException, @@message )
  end

  it "should enable a class to define a custom exception using a symbol" do
    class AnotherTest
      define_exception :AnotherException, @@message
    
      def test
        raise AnotherException
      end
    end

    at = AnotherTest.new

    lambda {
      at.test
    }.should raise_error( AnotherTest::AnotherException, @@message )
  end

  it "should enable a class to define a custom exception using a symbol converted to camel case" do
    class YetAnotherTest
      define_exception :yet_another_exception, @@message
    
      def test
        raise YetAnotherException
      end
    end

    yat = YetAnotherTest.new

    lambda {
      yat.test
    }.should raise_error( YetAnotherTest::YetAnotherException, @@message )
  end

  it "should enable a class to define a custom exception subclassing off of a different exception than RuntimeError" do
    class AnyAncestorTest
      define_exception 'MyArgException', @@message, 'ArgumentError'
    
      def test
        raise MyArgException
      end
    end

    mae = AnyAncestorTest.new
    lambda {
      mae.test
    }.should raise_error( AnyAncestorTest::MyArgException, @@message )

    begin
        mae.test
    rescue AnyAncestorTest::MyArgException => e
      e.is_a?( Exception ).should == true
      e.is_a?( StandardError ).should == true
      e.is_a?( ArgumentError ).should == true
    end
  end
end
