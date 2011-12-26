require "test_helper"
require "pinger/cli"

def bin
  @bin ||= File.expand_path("../../bin/pinger", __FILE__)
end

def cmd(command)
  capture_stdout do
    puts `#{bin} #{command}`
  end
end

def setup_uri(uri="http://example.com")
  @uri ||= Pinger::URI.find_or_create(:uri => uri) 
end

class CliTest < MiniTest::Unit::TestCase
  
  should "be executable" do
    assert File.executable?(bin)
  end

  should "return utility commands" do
    assert_equal %w(list stats help), Pinger::CLI::UTILITY_COMMANDS
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

  context "When listing uris" do
    
    def setup
      Pinger::URI.dataset.destroy
    end
    
    should "list uris and show empty message" do
      out = cmd("list")
      assert_equal "No uris have been added to pinger. Add a uri with `pinger add URI`", out
    end

    should "show usage for all uri commands if no argument is given" do
      Pinger::CLI::URI_COMMANDS.each do |command|
        assert_equal "Usage: pinger #{command} URI", cmd(command)
      end
    end
    
    context "With some existing uris" do
    
      def setup
        Pinger::URI.dataset.destroy
        3.times do |i|
          Pinger::URI.create(:uri => "http://#{i}.example.com")
        end
      end
    
      should "list uris" do
        out = cmd("list")
        assert_equal "http://0.example.com\nhttp://1.example.com\nhttp://2.example.com", out
      end
      
    end
  
  end
  
  context "When adding uris" do
    
    def setup
      Pinger::URI.dataset.destroy
    end
     
    should "add uri to database" do
      assert Pinger::URI.find(:uri => "http://example.com").nil?
      out = cmd("add http://example.com")
      assert !Pinger::URI.find(:uri => "http://example.com").nil?
      assert_equal "http://example.com was successfully added to pinger", out
    end
    
    should "not allow duplicate uris to be added" do
      setup_uri
      out = cmd("add http://example.com")
      assert_equal "http://example.com already exists in pinger", out
    end
    
  end

  context "When removing uris" do
    
    def setup
      setup_uri 
    end
    
    should "remove uri from database" do
      assert !Pinger::URI.find(:uri => "http://example.com").nil?
      out = cmd("rm http://example.com")
      assert Pinger::URI.find(:uri => "http://example.com").nil?
      assert_equal "http://example.com was successfully removed from pinger", out
    end
    
    should "not allow non-existant uris to be removed" do
      Pinger::URI.dataset.destroy
      out = cmd("rm http://example.com")
      assert_equal "http://example.com doesn't exist in pinger", out
    end
    
  end
  
  context "When showing a uri" do
  
    def setup
      setup_uri 
    end

    should "show warning when uri doesn't exist" do
      out = cmd("show http://nonexistant.example.com")
      assert_equal "http://nonexistant.example.com hasn't been added to pinger. Add it with `pinger add http://nonexistant.example.com`", out 
    end

    should "show uri" do
      out = cmd("show http://example.com")
      assert_match /^http:\/\/example.com\n/, out
      assert_match Regexp.new("#{@uri.pings.count} pings since #{@uri.created_at.formatted}"), out
    end 

  end

  context "When pinging a uri" do

    def setup
      setup_uri
    end

    should "show warning when uri doesn't exist" do
      out = cmd("ping http://nonexistant.example.com")
      assert_equal "http://nonexistant.example.com hasn't been added to pinger. Add it with `pinger add http://nonexistant.example.com`", out
    end

    should "ping uri" do
      outs = cmd("ping http://example.com").split("\n")
      assert_equal "pinging http://example.com...", outs.first
    end

  end

end

