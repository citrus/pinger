require "test_helper"

class URITest < MiniTest::Unit::TestCase

  def setup
    Pinger::URI.dataset.destroy
  end

  should "be a sequel model" do        
    assert Pinger::URI.ancestors.include?(Sequel::Model)
  end
  
  should "have table present in database" do        
    assert Pinger.db.table_exists?(:uris)
  end
  
  should "have proper attributes" do
    assert_equal [ :id, :uri, :created_at ], Pinger::URI.columns
  end
  
  should "save uri to database" do
    uri = Pinger::URI.new(:uri => "http://example.com")
    time = Time.now.to_i
    assert uri.save
    assert_equal time, uri.created_at.to_i
  end
  
  context "An existing uri" do
    
    def setup
      @uri = Pinger::URI.find_or_create(:uri => "http://example.com")
    end
    
    should "be deleted" do
      count = Pinger::URI.count
      @uri.destroy
      assert_equal count - 1, Pinger::URI.count
    end
    
  end
  
end
