require "test_helper"

def uri
  @uri ||= Pinger::URI.find_or_create(:uri => TEST_URI)
end

class AlertTest < MiniTest::Unit::TestCase
  
  should "be a sequel model" do        
    assert Pinger::Alert.ancestors.include?(Sequel::Model)
  end
  
  should "have table present in database" do        
    assert Pinger.db.table_exists?(:alerts)
  end
  
  should "have proper attributes" do
    assert_equal [ :id, :ping_id, :subject, :created_at ], Pinger::Alert.columns
  end
      
  should "belong to uri" do
    alert = Pinger::Alert.new
    assert alert.respond_to?(:uri)
    assert alert.uri.nil?
  end
  
  should "belong to ping" do
    alert = Pinger::Alert.new
    assert alert.respond_to?(:ping)
    assert alert.ping.nil?
  end
  
  context "When a uri's status changes" do
  
    def setup
      super
      Mail::TestMailer.deliveries = []
      @count = Pinger::Alert.count
      @ping1 = uri.request!
      stub_request(:get, TEST_URI).to_return(:status => 301)
    end
    
    should "be created when ping status changes" do
      ping2 = uri.request!
      alert = Pinger::Alert.order(:id).last
      assert_equal @count + 1, Pinger::Alert.count
      assert_equal 1, uri.alerts.count
      assert_equal "Status changed from 200 to 301", alert.subject
    end
    
    should "send mail when alert is created" do
      count = Mail::TestMailer.deliveries.length
      ping2 = uri.request!
      alert = Pinger::Alert.order(:id).last
      assert_equal count + 1, Mail::TestMailer.deliveries.length
      assert_equal "#{uri.uri} - #{alert.subject}", Mail::TestMailer.deliveries.last.subject
    end
  
  end
  
  context "With and existing alert" do
  
    def setup
      @ping  = uri.request!
      @alert = Pinger::Alert.create(:ping => @ping)
    end
    
    should "access uri through ping" do
      assert @ping.uri, @alert.uri
    end

  end
  
end
