require "test_helper"

class URITest < MiniTest::Unit::TestCase

  should "be a sequel model" do        
    assert Pinger::URI.ancestors.include?(Sequel::Model)
  end
  
  should "have table present in database" do        
    assert Pinger.db.table_exists?(:uris)
  end
  
  should "have proper attributes" do
    assert_equal [ :id, :uri, :scheme, :userinfo, :host, :port, :registry, :path, :opaque, :query, :fragment, :request_uri, :created_at ], Pinger::URI.columns
  end
  
  should "have many pings" do
    assert Pinger::URI.new.respond_to?(:pings)
  end
  
  should "have many alerts" do
    assert Pinger::URI.new.respond_to?(:alerts)
  end
    
  should "validate uri" do
    %w(255.255.255.277 0.0.0.256 .com invalid. http://in\ valid.com).each do |i|
      @uri = Pinger::URI.new(:uri => i)
      valid = @uri.valid? rescue false
      assert !valid
    end
  end
  
  should "save uri to database" do
    @uri = Pinger::URI.new(:uri => TEST_URI)
    assert @uri.save
    assert !@uri.created_at.nil?
  end
  
  context "An existing uri" do
    
    def setup
      super
      assert !uri.nil?
    end
    
    should "request and create ping" do
      uri.ping!
      assert_equal 1, Pinger::Ping.count
    end
    
    should "return id as to_param" do
      assert_equal uri.id, uri.to_param
    end
    
    should "convert created_at into FormattedTime" do
      assert_equal FormattedTime, uri.created_at.class
    end 
    
    should "return average response time" do
      @ping = uri.ping!
      assert_equal @ping.response_time, uri.average_response_time
    end
    
    should "return average response size" do
      @ping = uri.ping!
      assert_equal @ping.response_size, uri.average_response_size
    end
    
    should "be deleted" do
      count = Pinger::URI.count
      uri.destroy
      assert_equal count - 1, Pinger::URI.count
    end
            
  end
  
end
