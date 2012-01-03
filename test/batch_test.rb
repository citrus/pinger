require "test_helper"

class BatchTest < MiniTest::Unit::TestCase

  def setup
    super
    stub_request(:get, "www.example.com").to_return(:status => 301)
    stub_request(:get, "something-that-doesnt-exist-3.gov").to_return(:status => 400)
    
    Pinger::URI.dataset.destroy
    %w(example.com www.example.com something-that-doesnt-exist-3.gov).each do |uri|
      Pinger::URI.create(:uri => uri)
    end
  end
  
  should "run pings for all domains" do
    @batch = Pinger::Batch.new
    @batch.process
    assert_equal 3, Pinger::Ping.count
  end
  
end
