require "test_helper"
require "pinger/cli"

def bin
  @bin ||= File.expand_path("../../bin/pinger", __FILE__)
end

class CliTest < MiniTest::Unit::TestCase
  
  should "be executable" do
    assert File.executable?(bin)
  end

  should "return utility commands" do
    assert_equal %w(list stats batch flush config help), Pinger::CLI::UTILITY_COMMANDS
  end

  should "return uri commands" do
    assert_equal %w(add rm show ping), Pinger::CLI::URI_COMMANDS
  end

  should "return all commands" do
    assert Pinger::CLI::COMMANDS.is_a?(Array)
  end

  should "return help menu when invalid command is given" do
    out = `#{bin} invalid-command`
    assert_equal Pinger::CLI.run("help"), out
  end

  should "return usage for uri commands when uri is not specified" do
    Pinger::CLI::URI_COMMANDS.each do |command|
      assert_equal "Usage: pinger #{command} URI", Pinger::CLI.run(command)
    end
  end
  
  should "ensure all commands are defined in Pinger::Commands module" do
    Pinger::CLI::COMMANDS.each do |command|
      assert Pinger::CLI::Commands.respond_to?(command), "Pinger::Commands should respond to #{command}"
    end
  end
  
  should "list all commands in pinger help menu" do
    out = Pinger::CLI::Commands.help
    Pinger::CLI::COMMANDS.each do |command|
      assert out.include?("pinger #{command}"), "#{command} was not found in the help menu"
    end
  end
  
  should "show pinger config" do
    out = Pinger::CLI::Commands.config
    
  end
  
  should "normalize uri for uri commands" do
    domain = "example.com"
    Pinger::CLI::URI_COMMANDS.each do |command|
      out = Pinger::CLI.run(command, domain)
      assert out.include?("http://#{domain}"), "http://#{domain} should be included in `#{out}`"
    end
  end
  
  context "When listing uris" do
    
    should "list uris and show empty message" do
      out = Pinger::CLI::Commands.list
      assert_equal "No uris have been added to pinger. Add a uri with `pinger add URI`", out
    end
    
    context "With some existing uris" do
    
      def setup
        super
        3.times do |i|
          i = "http://v#{i}.example.com"
          Pinger::URI.create(:uri => i)
          stub_request(:get, i).to_return(:body => "<h1>Hello #{i}!</h1>", :status => 200)
        end
      end
      
      should "list uris" do
        out = Pinger::CLI::Commands.list
        assert_equal "http://v0.example.com\nhttp://v1.example.com\nhttp://v2.example.com", out
      end
      
      should "run batch" do
        out = Pinger::CLI::Commands.batch
        assert_match Regexp.new("#{Pinger::URI.count} pings completed in \\d+\\.\\d+ seconds"), out
      end
      
      should "flush pings from database" do
        out = Pinger::CLI::Commands.flush
        assert_match "deleted 0 alerts and 0 pings from pinger's database", out 
      end
      
      should "return stats for uri and pings" do
        out = Pinger::CLI::Commands.stats
        assert_equal "0 pings and 0 alerts on 3 uris", out
      end

    end
  
  end
  
  context "When adding uris" do
         
    should "add uri to database" do
      assert Pinger::URI.find(:uri => TEST_URI).nil?
      out = Pinger::CLI::Commands.add(TEST_URI)
      assert !Pinger::URI.find(:uri => TEST_URI).nil?
      assert_equal "http://example.com was successfully added to pinger", out
    end
     
    should "validate and error while adding invalid uri to database" do
      %w(255.255.255.277 0.0.0.256 .com invalid. https://in\ valid.com).each do |i|
        i = Pinger::URI.standardize(i)
        out = Pinger::CLI::Commands.add(i)
        assert Pinger::URI.find(:uri => i).nil?
        assert_equal "#{i} could not be added to pinger", out
      end
    end
    
    should "not allow duplicate uris to be added" do
      assert !uri.nil?
      out = Pinger::CLI::Commands.add(TEST_URI)
      assert_equal "http://example.com already exists in pinger", out
    end
    
  end

  context "When removing uris" do
    
    def setup
      super
      assert !uri.nil?
    end
    
    should "remove uri from database" do
      assert !Pinger::URI.find(:uri => TEST_URI).nil?
      out = Pinger::CLI::Commands.rm(TEST_URI)
      assert Pinger::URI.find(:uri => TEST_URI).nil?
      assert_equal "http://example.com was successfully removed from pinger", out
    end
    
    should "not allow non-existant uris to be removed" do
      Pinger::URI.dataset.destroy
      out = Pinger::CLI::Commands.rm(TEST_URI)
      assert_equal "http://example.com doesn't exist in pinger", out
    end
    
  end
  
  context "When showing a uri" do
  
    def setup
      super
      assert !uri.nil?
    end

    should "show warning when uri doesn't exist" do
      out = Pinger::CLI::Commands.show("http://nonexistant.example.com")
      assert_equal "http://nonexistant.example.com hasn't been added to pinger. Add it with `pinger add http://nonexistant.example.com`", out 
    end

    should "show uri" do
      out = Pinger::CLI::Commands.show(TEST_URI)
      assert_match /^http:\/\/example.com\n/, out
      assert_match Regexp.new("#{@uri.pings.count} pings since #{@uri.created_at.formatted}"), out
      assert_match Regexp.new("average: #{@uri.average_response_size}kb in #{@uri.average_response_time}s"), out
      assert out.include?(@uri.pings.map(&:stats).join("\n"))
    end

  end

  context "When pinging a uri" do

    def setup
      super
      assert !uri.nil?
    end

    should "show warning when uri doesn't exist" do
      out = Pinger::CLI::Commands.ping("http://nonexistant.example.com")
      assert_equal "http://nonexistant.example.com hasn't been added to pinger. Add it with `pinger add http://nonexistant.example.com`", out
    end

    should "ping uri" do
      out = Pinger::CLI::Commands.ping(TEST_URI)
      ping = Pinger::Ping.order(:id).last
      assert_equal ping.summary, out
    end

  end

end
