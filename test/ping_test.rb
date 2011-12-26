require "test_helper"

def domain
  @domain ||= Pinger::Domain.find_or_create(:domain => "www.google.com")
end

class PingTest < MiniTest::Unit::TestCase

  should "be a sequel model" do        
    assert Pinger::Ping.ancestors.include?(Sequel::Model)
  end
  
  should "have table present in database" do        
    assert Pinger.db.table_exists?(:pings)
  end
  
  should "have proper attributes" do
    assert_equal [ :id, :domain_id, :status, :response, :response_time, :created_at ], Pinger::Ping.columns
  end
  
  should "save ping to database" do
    ping = Pinger::Ping.new(:domain_id => domain.id)
    time = Time.now.to_i
    assert ping.save
    assert_equal time, ping.created_at.to_i
  end
  
  context "An existing ping for a valid domain" do
    
    def setup
      @ping = Pinger::Ping.create(:domain_id => domain.id)
    end

    should "send request and save response" do
      @ping.request!
      ping = Pinger::Ping.order(:id).last
      assert_equal 200, ping.status
      assert_equal @ping.response_time, ping.response_time
    end

    should "be deleted" do
      count = Pinger::Ping.count
      @ping.destroy
      assert_equal count - 1, Pinger::Ping.count
    end
  
  end
  
  context "And existing ping for an unreachable domain" do
    
    def setup
      domain.update(:domain => "something.that.doesnt.exist.example.com")
      @ping = Pinger::Ping.create(:domain_id => domain.id)
      @ping.request!
    end
    
    should "set response code to bad request" do
      assert_equal 400, @ping.status
    end
        
  end

end
