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

def setup_domain(domain="example.com")
  @domain ||= Pinger::Domain.find_or_create(:domain => domain) 
end

class CliTest < MiniTest::Unit::TestCase
  
  should "be executable" do
    assert File.executable?(bin)
  end

  should "return server commands" do
    assert_equal %w(start stop status), Pinger::CLI::SERVER_COMMANDS
  end

  should "return utility commands" do
    assert_equal %w(list stats help), Pinger::CLI::UTILITY_COMMANDS
  end

  should "return domain commands" do
    assert_equal %w(add rm show ping), Pinger::CLI::DOMAIN_COMMANDS
  end

  should "return all commands" do
    assert Pinger::CLI::COMMANDS.is_a?(Array)
  end

  should "ensure all commands are defined in Pinger::Commands module" do
    Pinger::CLI::COMMANDS.each do |command|
      assert Pinger::CLI::Commands.respond_to?(command), "Pinger::Commands should respond to #{command}"
    end
  end

  context "When listing domains" do
    
    def setup
      Pinger::Domain.dataset.destroy
    end
    
    should "list domains and show empty message" do
      out = cmd("list")
      assert_equal "No domains have been added to pinger. Add a domain with `pinger add DOMAIN`", out
    end

    should "show usage for all domain commands if no argument is given" do
      Pinger::CLI::DOMAIN_COMMANDS.each do |command|
        assert_equal "Usage: pinger #{command} DOMAIN", cmd(command)
      end
    end
    
    context "With some existing domains" do
    
      def setup
        Pinger::Domain.dataset.destroy
        3.times do |i|
          Pinger::Domain.create(:domain => "#{i}.example.com")
        end
      end
    
      should "list domains" do
        out = cmd("list")
        assert_equal "0.example.com\n1.example.com\n2.example.com", out
      end
      
    end
  
  end
  
  context "When adding domains" do
    
    def setup
      Pinger::Domain.dataset.destroy
    end
     
    should "add domain to database" do
      assert Pinger::Domain.find(:domain => "example.com").nil?
      out = cmd("add example.com")
      assert !Pinger::Domain.find(:domain => "example.com").nil?
      assert_equal "example.com was successfully added to pinger", out
    end
    
    should "not allow duplicate domains to be added" do
      setup_domain
      out = cmd("add example.com")
      assert_equal "example.com already exists in pinger", out
    end
    
  end

  context "When removing domains" do
    
    def setup
      setup_domain 
    end
    
    should "remove domain from database" do
      assert !Pinger::Domain.find(:domain => "example.com").nil?
      out = cmd("rm example.com")
      assert Pinger::Domain.find(:domain => "example.com").nil?
      assert_equal "example.com was successfully removed from pinger", out
    end
    
    should "not allow non-existant domains to be removed" do
      Pinger::Domain.dataset.destroy
      out = cmd("rm example.com")
      assert_equal "example.com doesn't exist in pinger", out
    end
    
  end
  
  context "When showing a domain" do
  
    def setup
      setup_domain 
    end

    should "show warning when domain doesn't exist" do
      out = cmd("show nonexistant.example.com")
      assert_equal "nonexistant.example.com hasn't been added to pinger. Add it with `pinger add nonexistant.example.com`", out 
    end

    should "show domain" do
      out = cmd("show example.com")
      assert_match /^example.com\n/, out
      assert_match Regexp.new("#{@domain.pings.count} pings since #{@domain.created_at}"), out
    end 

  end

  context "When pinging a domain" do

    def setup
      setup_domain
    end

    should "show warning when domain doesn't exist" do
      out = cmd("show nonexistant.example.com")
      assert_equal "nonexistant.example.com hasn't been added to pinger. Add it with `pinger add nonexistant.example.com`", out
    end

    should "ping domain" do
      outs = cmd("ping example.com").split("\n")
      assert_equal "pinging example.com...", outs.first
    end

  end

end

