require "test_helper"

class PingTest < MiniTest::Unit::TestCase

  should "be a sequel model" do        
    assert Pinger::Ping.ancestors.include?(Sequel::Model)
  end
  
  should "have table present in database" do        
    assert Pinger.db.table_exists?(:pings)
  end
  
  should "have proper attributes" do
    assert_equal [ :id, :uri_id, :status, :response, :response_time, :response_size, :created_at ], Pinger::Ping.columns
  end
  
  should "belong to uri" do
    assert Pinger::Ping.new.respond_to?(:uri)
  end
  
  should "have many alerts" do
    assert Pinger::Ping.new.respond_to?(:alerts)
  end
  
  context "A new, unsaved ping" do
    
    def setup
      super
      @ping = Pinger::Ping.new(:uri_id => uri.id)
      @request = @ping.send(:http_request)
    end
    
    should "save to database and set timestamp" do
      assert @ping.save
      assert !@ping.created_at.nil?
    end
    
    should "return http get request" do
      assert_equal Net::HTTP::Get, @request.class
    end
    
    should "set no cache and user agent headers" do
      assert_equal "no-cache", @request["cache-control"]
      assert_equal "Pinger v#{Pinger::VERSION}", @request["user-agent"]
    end
  
  end
  
  context "An existing ping for a valid uri" do
    
    def setup
      super
      @body = "Hello World! " * 1000
      @body_size = @body.bytesize
      stub_request(:get, TEST_URI).to_return(:body => @body, :status => 200)
      @ping = Pinger::Ping.create(:uri_id => uri.id)
      @ping.request!
    end

    should "send request and save response" do
      ping = Pinger::Ping.order(:id).last
      assert_equal 200, ping.status
      assert_equal @ping.response_time, ping.response_time
    end
    
    should "save response size" do
      assert_equal @body_size, @ping.response_size
    end
    
    should "convert response size to kb" do
      assert_equal 12.695, @ping.response_size_kb
    end
    
    should "calculate response size difference" do
      @ping.update(:response_size => 1024)
      @ping2 = uri.request!
      assert_equal 11.695, @ping2.response_size_difference_kb
    end
    
    should "return ping stats" do
      assert_equal [ @ping.created_at.formatted, @ping.status, "#{@ping.response_time}s", "#{@ping.response_size_kb}kb"  ].join(", "), @ping.stats
    end
        
    should "create a status change alert" do
      stub_request(:get, TEST_URI).to_return(:status => 301)
      ping2 = uri.request!
      assert !ping2.alerts.empty?
      assert_equal "Status changed from 200 to 301", ping2.alerts.first.subject
    end
    
    should "create a response time alert" do
      @ping.update(:response_time => 10)
      ping2 = uri.request!
      assert !ping2.alerts.empty?
      assert_equal "Unusual response time difference; #{ping2.response_time_difference}s", ping2.alerts.first.subject
    end
    
    should "create a response size alert" do
      @ping.update(:response_size => 1)
      ping2 = uri.request!
      assert !ping2.alerts.empty?
      assert_equal "Unusual response size difference; #{ping2.response_size_difference_kb}kb", ping2.alerts.first.subject
    end
    
    should "return ping summary" do
      assert_equal "#{@ping.created_at.formatted} - #{@ping.uri.uri} downloaded #{@ping.response_size_kb}kb in #{@ping.response_time} seconds with status #{@ping.status}", @ping.summary
    end
    
    should "return id as to_param" do
      assert_equal @ping.id, @ping.to_param
    end
    
    should "be deleted" do
      count = Pinger::Ping.count
      @ping.destroy
      assert_equal count - 1, Pinger::Ping.count
    end
  
  end
  
  context "And existing ping for an unreachable uri" do
    
    def setup
      super
      uri.set(:uri => "http://localhost:11111").save
      @ping = Pinger::Ping.create(:uri_id => uri.id)
      @ping.request!
    end
    
    should "set response code to bad request" do
      assert_equal 400, @ping.status
    end
        
  end

end
