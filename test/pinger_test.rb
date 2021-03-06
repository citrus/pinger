require "test_helper"

class PingerTest < MiniTest::Unit::TestCase

  should "read config file and initialize config" do  
    assert Pinger.config.is_a?(Pinger::Config)
  end
    
  should "establish database connection" do
    assert !Pinger.connection.nil?
  end

  should "alias connection to Pinger.db" do  
    assert_equal Pinger.connection, Pinger.db
  end
  
  should "create schema on init" do
    assert Pinger.db.table_exists?(:uris)
    assert Pinger.db.table_exists?(:pings)
    assert Pinger.db.table_exists?(:alerts)
  end
  
  context "When pinger config path isn't present" do
  
    def setup
      super
      clear_pinger_config
      ENV["PINGER_CONFIG"] = nil      
    end
    
    def teardown
      reset_pinger_config
    end
      
    should "default pinger config path" do
      assert_equal File.expand_path("~/.pinger.yml"), Pinger.config_path
    end
    
  end
  
  context "When a non invalid database url is provided" do
  
    def setup
      @db_url = Pinger.config[:database_url]
      Pinger.config[:database_url] = "invalid://"
      Pinger.instance_variable_set("@connection", nil)
    end
    
    def teardown
      Pinger.config[:database_url] = @db_url
      Pinger.instance_variable_set("@connection", nil)
      Pinger.connect
    end
    
    should "raise config error" do
      assert_raises Pinger::DatabaseError do
        Pinger.connect
      end
    end
    
  end
  
end
