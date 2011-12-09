require "test_helper"

class PingerTest < MiniTest::Unit::TestCase

  should "establish database connection" do        
    assert !Pinger.connection.nil?
  end
  
  should "alias connection to Pinger.db" do  
    assert_equal Pinger.connection, Pinger.db
  end
  
  should "be a sqlite connection" do
    assert Pinger.db.is_a?(Sequel::SQLite::Database)
  end
  
  should "create schema on init" do
    assert Pinger.db.table_exists?(:domains)
    assert Pinger.db.table_exists?(:pings)
  end

end
