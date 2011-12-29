require "test_helper"

class PingerTest < MiniTest::Unit::TestCase

  should "establish database connection" do
    assert !Pinger.connection.nil?
  end
  
  should "raise database error when invalid database url is provided" do
    db_url = ENV["PINGER_DB"]
    Pinger.instance_variable_set("@connection", nil)
    ENV["PINGER_DB"] = "invalid://"
    assert_raises Pinger::DatabaseError do
      Pinger.connect
    end
    ENV["PINGER_DB"] = db_url
  end

  should "alias connection to Pinger.db" do  
    assert_equal Pinger.connection, Pinger.db
  end
  
  should "create schema on init" do
    assert Pinger.db.table_exists?(:uris)
    assert Pinger.db.table_exists?(:pings)
  end
  
end
