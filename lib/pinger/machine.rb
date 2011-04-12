module Pinger

  module Machine
  
    def receive_data(data)
      p data
    end
  
  end

end

EM.run {
  EM.start_server("127.0.0.1", 8080, Pinger::Machine)
}