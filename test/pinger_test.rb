require "test_helper"

class PingerTest < MiniTest::Unit::TestCase

  should "establish database connection" do        
    assert !Pinger.connection.nil?
  end

  should "be a sqlite connection" do
    assert Pinger.connection.is_a?(Sequel::SQLite::Database)
  end

end
