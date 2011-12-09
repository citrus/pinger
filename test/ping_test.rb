require "test_helper"

class PingTest < MiniTest::Unit::TestCase

  def setup
    @domain = Pinger::Domain.find_or_create(:domain => "example.com")
  end
  
  should "be a sequel model" do        
    assert Pinger::Ping.ancestors.include?(Sequel::Model)
  end
  
  should "have table present in database" do        
    assert Pinger.db.table_exists?(:pings)
  end
  
  should "have proper attributes" do
    assert_equal [ :id, :domain_id, :status, :response, :created_at ], Pinger::Ping.columns
  end
  
  should "save domain to database" do
    ping = Pinger::Ping.new(:domain_id => @domain.id)
    assert ping.save
    assert_equal Time.now.to_i, ping.created_at.to_i
  end
  
  context "An existing ping" do
    
    def setup
      @domain = Pinger::Domain.find_or_create(:domain => "sub.example.com")
      @ping = Pinger::Ping.create(:domain_id => @domain.id)
    end
    
    should "be deleted" do
      count = Pinger::Ping.count
      @ping.destroy
      assert_equal count - 1, Pinger::Ping.count
    end
    
  end
  
end
