begin
  require 'simplecov'
  SimpleCov.start
rescue Exception
  puts "Install simplecov for test coverage..."
end

#ENV["PINGER_DB"] = ENV["PINGER_TEST_DB"] || "sqlite://test/db/pinger.db"

ENV["PINGER_CONFIG"] = File.expand_path("../.pinger.test.yml", __FILE__)

gem "minitest"
require "minitest/autorun"
require "minitest/should"
begin require "turn"; rescue LoadError; end

require "pinger"
Pinger.reset_database!
