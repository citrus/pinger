require "test_helper"

class ConfigTest < MiniTest::Unit::TestCase

  def setup
    @config = Pinger::Config.new(ENV["PINGER_CONFIG"])
  end

  should "subclass hash" do
    assert Pinger::Config.ancestors.include?(Hash)
  end
  
  should "include database url and notification email in config hash" do
    assert !@config["database_url"].nil?
    assert !@config["email_to"].nil?
  end
  
  should "include pinger config defaults" do
    Pinger::Config.defaults.each do |k, v|
      assert !@config[k].nil?
    end
  end
  
  context "When a non existent config file is specified" do
  
    def setup
      @config_path = ENV["PINGER_CONFIG"]
      ENV["PINGER_CONFIG"] = "/some/non/existent/file-2.yml"
      Pinger.instance_variable_set("@config", nil)
    end
    
    def teardown
      ENV["PINGER_CONFIG"] = @config_path
      Pinger.instance_variable_set("@config", nil)
      Pinger.config
    end
    
    should "raise config error" do
      assert_raises Pinger::ConfigError do
        Pinger.config
      end
    end
    
  end
  
end
