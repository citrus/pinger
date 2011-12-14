require "test_helper"

class DomainTest < MiniTest::Unit::TestCase

  def setup
    Pinger::Domain.dataset.destroy
  end

  should "be a sequel model" do        
    assert Pinger::Domain.ancestors.include?(Sequel::Model)
  end
  
  should "have table present in database" do        
    assert Pinger.db.table_exists?(:domains)
  end
  
  should "have proper attributes" do
    assert_equal [ :id, :domain, :created_at ], Pinger::Domain.columns
  end
  
  should "save domain to database" do
    domain = Pinger::Domain.new(:domain => "example.com")
    time = Time.now.to_i
    assert domain.save
    assert_equal time, domain.created_at.to_i
  end
  
  context "An existing domain" do
    
    def setup
      @domain = Pinger::Domain.find_or_create(:domain => "example.com")
    end
    
    should "be deleted" do
      count = Pinger::Domain.count
      @domain.destroy
      assert_equal count - 1, Pinger::Domain.count
    end
    
  end
  
end
