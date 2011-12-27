require "test_helper"
require "pinger/cli"

def bin
  @bin ||= File.expand_path("../../bin/pinger", __FILE__)
end

def setup_uri(uri="http://example.com")
  @uri ||= Pinger::URI.find_or_create(:uri => uri) 
end

class CliTest < MiniTest::Unit::TestCase
  
  should "be executable" do
    assert File.executable?(bin)
  end

  should "return utility commands" do
    assert_equal %w(list stats batch flush help), Pinger::CLI::UTILITY_COMMANDS
  end

  should "return uri commands" do
    assert_equal %w(add rm show ping), Pinger::CLI::URI_COMMANDS
  end

  should "return all commands" do
    assert Pinger::CLI::COMMANDS.is_a?(Array)
  end

  should "ensure all commands are defined in Pinger::Commands module" do
    Pinger::CLI::COMMANDS.each do |command|
      assert Pinger::CLI::Commands.respond_to?(command), "Pinger::Commands should respond to #{command}"
    end
  end
  
  should "return usage for uri commands if uri isn't passed as an argument" do
    Pinger::CLI::URI_COMMANDS.each do |command|
      assert_equal Pinger::CLI.usage(command), Pinger::CLI.run(command, [])
    end
  end
  
  context "When listing uris" do
    
    def setup
      Pinger::URI.dataset.destroy
    end
    
    should "list uris and show empty message" do
      out = Pinger::CLI::Commands.list
      assert_equal "No uris have been added to pinger. Add a uri with `pinger add URI`", out
    end
    
    context "With some existing uris" do
    
      def setup
        Pinger::URI.dataset.destroy
        3.times do |i|
          Pinger::URI.create(:uri => "http://#{i}.example.com")
        end
      end
    
      should "list uris" do
        out = Pinger::CLI::Commands.list
        assert_equal "http://0.example.com\nhttp://1.example.com\nhttp://2.example.com", out
      end
      
      should "run batch" do
        out = Pinger::CLI::Commands.batch
        assert_match Regexp.new("#{Pinger::URI.count} pings completed in \\d+\\.\\d+ seconds"), out
      end
      
      should "flush pings from database" do
        count = Pinger::Ping.count
        out = Pinger::CLI::Commands.flush
        assert_match "deleted #{count} pings from pinger's database", out 
      end
      
      should "return stats for uri and pings" do
        out = Pinger::CLI::Commands.stats
        assert_equal "0 pings on 3 uris", out
      end

      should "return help menu" do
        out = Pinger::CLI::Commands.help
        Pinger::CLI::URI_COMMANDS.each do |command|
          out.include?(command)
        end
      end

    end
  
  end
  
  context "When adding uris" do
    
    def setup
      Pinger::URI.dataset.destroy
    end
     
    should "add uri to database" do
      assert Pinger::URI.find(:uri => "http://example.com").nil?
      out = Pinger::CLI::Commands.add("http://example.com")
      assert !Pinger::URI.find(:uri => "http://example.com").nil?
      assert_equal "http://example.com was successfully added to pinger", out
    end
    
    should "not allow duplicate uris to be added" do
      setup_uri
      out = Pinger::CLI::Commands.add("http://example.com")
      assert_equal "http://example.com already exists in pinger", out
    end
    
  end

  context "When removing uris" do
    
    def setup
      setup_uri 
    end
    
    should "remove uri from database" do
      assert !Pinger::URI.find(:uri => "http://example.com").nil?
      out = Pinger::CLI::Commands.rm("http://example.com")
      assert Pinger::URI.find(:uri => "http://example.com").nil?
      assert_equal "http://example.com was successfully removed from pinger", out
    end
    
    should "not allow non-existant uris to be removed" do
      Pinger::URI.dataset.destroy
      out = Pinger::CLI::Commands.rm("http://example.com")
      assert_equal "http://example.com doesn't exist in pinger", out
    end
    
  end
  
  context "When showing a uri" do
  
    def setup
      setup_uri 
    end

    should "show warning when uri doesn't exist" do
      out = Pinger::CLI::Commands.show("http://nonexistant.example.com")
      assert_equal "http://nonexistant.example.com hasn't been added to pinger. Add it with `pinger add http://nonexistant.example.com`", out 
    end

    should "show uri" do
      out = Pinger::CLI::Commands.show("http://example.com")
      assert_match /^http:\/\/example.com\n/, out
      assert_match Regexp.new("#{@uri.pings.count} pings since #{@uri.created_at.formatted}"), out
    end 

  end

  context "When pinging a uri" do

    def setup
      setup_uri
    end

    should "show warning when uri doesn't exist" do
      out = Pinger::CLI::Commands.ping("http://nonexistant.example.com")
      assert_equal "http://nonexistant.example.com hasn't been added to pinger. Add it with `pinger add http://nonexistant.example.com`", out
    end

    should "ping uri" do
      out = Pinger::CLI::Commands.ping("http://example.com")
      ping = Pinger::Ping.order(:id).last
      assert_equal "#{ping.created_at.formatted} - http://example.com finished in #{ping.response_time} seconds with status #{ping.status}", out
    end

  end

end
