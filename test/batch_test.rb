require "test_helper"

class BatchTest < MiniTest::Unit::TestCase

  def setup
    Pinger::Ping.dataset.destroy
    %w(www.google.com example.com something-that-doesnt-exist-3.gov).each do |uri|
      Pinger::URI.create(:uri => uri)
    end
  end
  
  should "run pings for all domains" do
    @batch = Pinger::Batch.new
    @batch.process
    assert_equal 3, Pinger::Ping.count
  end
  
end
