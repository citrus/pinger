require 'helper'

class TestPinger < Test::Unit::TestCase

  should "add a url to the list" do
        
    assert_equal 1, Site.all
    
  end

end