require "test_helper"

class FormattedTimeTest < MiniTest::Unit::TestCase

  def setup
    @time = FormattedTime.new(2011, 12, 26, 10, 10, 10)
  end

  should "respond to formatted method" do
    assert @time.respond_to?(:formatted)
  end
  
  should "format time" do
    assert_equal "12/26/2011 10:10am", @time.formatted
  end
  
end
