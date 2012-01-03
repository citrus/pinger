begin
  require 'simplecov'
  SimpleCov.start
rescue Exception
  puts "Install simplecov for test coverage..."
end

ENV["PINGER_CONFIG"] = File.expand_path("../.pinger.test.yml", __FILE__)

gem "minitest"
require "minitest/autorun"
require "minitest/should"
require "webmock/minitest"

begin require "turn"; rescue LoadError; end

require "pinger"
Pinger.reset_database!

TEST_URI = "http://example.com"

module MiniTest
  class Unit
    class TestCase    
      def setup
        stub_request(:get, TEST_URI).to_return(:status => 200)
      end
    end
  end
end
