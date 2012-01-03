require "test_helper"

class FormattedTimeTest < MiniTest::Unit::TestCase

  def setup
    @time = FormattedTime.new(2012, 1, 1, 1, 1, 1)
    @time2 = FormattedTime.new(2010, 10, 10, 10, 10, 10)
  end

  should "respond to formatted method" do
    assert @time.respond_to?(:formatted)
  end
  
  should "strip all leading zeros in formatted time" do
    assert_equal "1/1/2012 1:01:01am", @time.formatted
  end
  
  should "ensure only leading zeros are stripped" do
    assert_equal "10/10/2010 10:10:10am", @time2.formatted
  end
  
end
