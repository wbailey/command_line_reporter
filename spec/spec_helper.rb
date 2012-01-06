$: << File.join(File.dirname(__FILE__), '..', 'lib')

Dir[File.dirname(__FILE__) + "../lib/*.rb"].each {|f| require f}
Dir[File.dirname(__FILE__) + "/support/**/*.rb"].each {|f| require f}
