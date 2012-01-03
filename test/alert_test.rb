require "test_helper"

def uri
  @uri ||= Pinger::URI.find_or_create(:uri => "http://www.google.com")
end

class AlertTest < MiniTest::Unit::TestCase
  
  should "be a sequel model" do        
    assert Pinger::Alert.ancestors.include?(Sequel::Model)
  end
  
  should "have table present in database" do        
    assert Pinger.db.table_exists?(:alerts)
  end
  
  should "have proper attributes" do
    assert_equal [ :id, :uri_id, :ping_id, :created_at ], Pinger::Alert.columns
  end
      
  should "belong to uri" do
    assert Pinger::Alert.new.respond_to?(:uri)
  end
  
  should "belong to uri" do
    assert Pinger::Alert.new.respond_to?(:ping)
  end
  
  context "With and existing alert" do
  
    def setup
      @ping  = uri.request!
      @alert = Pinger::Alert.create(:uri => uri, :ping => @ping)
    end

        
  end
  
end
