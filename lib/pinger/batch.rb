module Pinger
  class Batch
    
    attr_reader :uris
    
    def initialize(_uris=nil)
      @uris = _uris || Pinger::URI.order(:uri).all
    end
    
    def process
      uris.each do |uri|
        ping = uri.request!
        puts "#{ping.created_at.formatted} - #{uri.uri} finished in #{ping.response_time} seconds with status #{ping.status}"
      end
    end
      
  end
end
