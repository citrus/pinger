require "test_helper"

def bin
  @bin ||= File.expand_path("../../bin/pinger", __FILE__)
end

def cmd(*args)
  capture_stdout do
    puts `#{bin} #{args.join(" ")}`
  end
end

class CliTest < MiniTest::Unit::TestCase

  def setup
    Pinger::Domain.dataset.destroy
  end

  should "be executable" do
    assert File.executable?(bin)
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
