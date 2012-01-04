module Pinger
  class Batch
    
    attr_reader :uris
    
    def initialize(_uris=nil)
      @uris = _uris || Pinger::URI.order(:uri).all
    end
    
    def process
      uris.each do |uri|
        ping = uri.ping!
        puts ping.summary
      end
    end
      
  end
end
