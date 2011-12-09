require "test_helper"

class CliTest < MiniTest::Unit::TestCase

  def bin
    @bin ||= File.expand_path("../../bin/pinger", __FILE__)
  end

  should "be executable" do
    assert File.executable?(bin)
  end

end
