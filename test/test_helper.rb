begin
  require 'simplecov'
  SimpleCov.start
rescue Exception
  puts "Install simplecov for test coverage..."
end

ENV["PINGER_DB"] = ENV["PINGER_TEST_DB"] || "sqlite://test/db/pinger.db"

gem "minitest"
require "minitest/autorun"
require "minitest/should"
begin require "turn"; rescue LoadError; end

require "pinger"
Pinger.reset_database!

# Load support files
Dir["#{File.dirname(__FILE__)}/support/**/*.rb"].each { |f| require f }
