require "test_helper"

class CliTest < MiniTest::Unit::TestCase

  def bin
    @bin ||= File.expand_path("../../bin/pinger", __FILE__)
  end

  def cmd(*args)
    capture_stdout do
      `#{bin} #{args.join(" ")}`
    end
  end

  should "be executable" do
    assert File.executable?(bin)
  end

  should "list domains" do
    out = cmd("list")
    
  end

end
