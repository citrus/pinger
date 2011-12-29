require "test_helper"

def uri
  @uri ||= Pinger::URI.find_or_create(:uri => "http://www.google.com")
end

class PingTest < MiniTest::Unit::TestCase

  should "be a sequel model" do        
    assert Pinger::Ping.ancestors.include?(Sequel::Model)
  end
  
  should "have table present in database" do        
    assert Pinger.db.table_exists?(:pings)
  end
  
  should "have proper attributes" do
    assert_equal [ :id, :uri_id, :status, :response, :response_time, :created_at ], Pinger::Ping.columns
  end
  
  should "save ping to database" do
    ping = Pinger::Ping.new(:uri_id => uri.id)
    assert ping.save
    assert !ping.created_at.nil?
  end
  
  context "An existing ping for a valid uri" do
    
    def setup
      @ping = Pinger::Ping.create(:uri_id => uri.id)
    end

    should "send request and save response" do
      @ping.request!
      ping = Pinger::Ping.order(:id).last
      assert_equal 200, ping.status
      assert_equal @ping.response_time, ping.response_time
    end
    
    should "return ping stats" do
      assert_equal [ @ping.created_at.formatted, @ping.status, "#{@ping.response_time}s"  ].join(", "), @ping.stats
    end

    should "be deleted" do
      count = Pinger::Ping.count
      @ping.destroy
      assert_equal count - 1, Pinger::Ping.count
    end
  
  end
  
  context "And existing ping for an unreachable uri" do
    
    def setup
      uri.update(:uri => "127.0.0.0")
      @ping = Pinger::Ping.create(:uri_id => uri.id)
      @ping.request!
    end
    
    should "set response code to bad request" do
      assert_equal 400, @ping.status
    end
        
  end

end
