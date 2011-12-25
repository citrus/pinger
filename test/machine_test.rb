require "test_helper"
require "thread"

class MachineTest < MiniTest::Unit::TestCase
  
  should "start event machine" do
    started = false
    EM.run {
      started = Pinger::Machine.start
      EM.stop
    }
    assert started
  end
  
  should "stop event machine" do
    stopped = false
    EM.run {
      Pinger::Machine.start
      stopped = Pinger::Machine.stop
    }
    assert stopped
  end
  
end
