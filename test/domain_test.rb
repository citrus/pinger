require "test_helper"

class DomainTest < MiniTest::Unit::TestCase

  should "be a sequel model" do        
    assert Pinger::Domain.ancestors.include?(Sequel::Model)
  end

end
