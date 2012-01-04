require "test_helper"

class ConfigTest < MiniTest::Unit::TestCase

  def setup
    @config = Pinger::Config.new(ENV["PINGER_CONFIG"])
  end

  should "subclass hash" do
    assert Pinger::Config.ancestors.include?(Hash)
  end
    
  should "include pinger config defaults" do
    Pinger::Config.defaults.each do |k, v|
      assert !@config[k].nil?
    end
  end
  
  should "set default template directory" do
    assert_equal File.expand_path("../../lib/pinger/templates", __FILE__), Pinger::Config.default_template_directory
  end
  
  should "initialize config in pinger lib" do
    assert Pinger.config.is_a?(Hash)
  end
  
  should "convert all keys to symbols" do
    assert_equal [ Symbol ], Pinger.config.keys.map(&:class).uniq
  end
  
  should "access value with string or symbol" do
    assert_equal Pinger.config[:database_url], Pinger.config["database_url"]
  end
  
  should "convert keys to symbols when storing" do
    Pinger.config["something"] = "nothing"
    assert Pinger.config.keys.include?(:something)
  end
  
  should "configure mail during initialization" do
    hash = {}
    assert_equal :test, Pinger.config[:delivery_method]
    assert_equal hash, Pinger.config[:delivery_method_options]
  end
  
  context "When a non existent config file is specified" do
  
    def setup
      clear_pinger_config
      ENV["PINGER_CONFIG"] = "/some/non/existent/file-2.yml"      
    end
    
    def teardown
      reset_pinger_config
    end
    
    should "raise config error" do
      assert_raises Pinger::ConfigError do
        Pinger.config
      end
    end
    
  end
  
end
