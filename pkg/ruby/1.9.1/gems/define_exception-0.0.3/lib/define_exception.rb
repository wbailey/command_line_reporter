# Simple mixin that provides a way of defining custom exception classes
# with default messages that dries up your code.
#
# = Class Methods
#
# <tt>define_exception</tt>( <i>ExceptionName</i>, <i>'Default Error Message'</i> )
#
# The exception name can either be a <i>string</i> or a <i>symbol</i>.  If it is a <i>string</i>
# then the name will be as provided.  In the <i>symbol</i> case if the symbol is mixed case the
# result exception name will be as provided.  You also have the option of using underscores and having
# the method automatically generate the mixed case exception name:
#
#     define_exception 'MyError', 'The Default Message'
#     define_exception :AnotherError, 'Another Default Message'
#     define_exception :worst_error, 'Worst Default Message'
#
# Any of the above methods will work.
#
# = Usage
#
# The standard ruby practice of requiring the gem and then use <i>include DefineException</i> to
# make the class method available.
#
# = Example
#
#    require 'rubygems'
#    require 'define_exception'
#
#    include DefineException
#
#    class Test
#      define_exception :test_me, 'this is the default message'
#
#      def test
#        raise TestMe
#      end
#
#      def test2
#        raise( TestMe, 'You shall not do that again' )
#      end
#    end
#
#    t = Test.new
#
#    begin
#      t.test
#    rescue Test::TestMe => e
#      puts e.message
#    end
#
#    t.test2
#
# running the above example would correctly produce
#
#    wes:~/define_exception/examples> ruby sample.rb
#    this is the default message
#    test.rb:14:in `test2': You shall not do that again (Test::TestMe)
#        from test.rb:26
#
# = Information
#
# Author:: Wes Bailey, wes@verticalresponse.com
# License:: Ruby License

class String
  def lame_camel_case
    /_/.match( self ) ? self.to_s.split( '_' ).inject( '' ) { |s,v| s << v.capitalize } : self
  end
end

module DefineException
  module ClassMethods
    def define_exception( exception, default_message = 'Application Error Occurred', ancestor = 'RuntimeError' )
      class_eval <<-EOD
        class #{exception.to_s.lame_camel_case} < #{ancestor.to_s.lame_camel_case}
          def initialize( message = nil )
            super( message || "#{default_message}" )
          end
        end
      EOD
    end
  end

  class << self
    def included( base )
      base.extend( ClassMethods )
    end
  end
end
