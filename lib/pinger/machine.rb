require "eventmachine"

module Pinger
  module Machine
  
    def self.start
      EM.run {
        
      }
      EM.reactor_running?
    end
    
    def self.stop
      EM.stop
      EM.reactor_running?
    end
    
  end
end
