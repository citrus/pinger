require "test_helper"

def bin
  @bin ||= File.expand_path("../../bin/pinger", __FILE__)
end

def cmd(command)
  capture_stdout do
    puts `#{bin} #{command}`
  end
end

class CliTest < MiniTest::Unit::TestCase
  
  should "be executable" do
    assert File.executable?(bin)
  end

  context "When listing domains" do
    
    def setup
      Pinger::Domain.dataset.destroy
    end
    
    should "list domains and show empty message" do
      out = cmd("list")
      assert_equal "No domains have been added to pinger. Add a domain with `pinger add DOMAIN`", out
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
      Pinger::Domain.find_or_create(:domain => "example.com")
      out = cmd("add example.com")
      assert_equal "example.com already exists in the pinger database", out
    end
    
  end

end
