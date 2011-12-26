require 'net/http'
require 'uri'

module Pinger
  class Ping < Sequel::Model
    
    many_to_one :domain
    
    plugin :timestamps

    def request! 
      perform_request
    end

    private 

      def perform_request
        time = Time.now.to_f
        uri  = URI.parse(domain.url)
        
        begin
          @res = Net::HTTP.get_response(uri)
        rescue SocketError => e
          # bad request...
        end
        
        self.response_time = (Time.now.to_f - time).round(3)
        
        unless @res.nil?
          self.status = @res.code.to_i
          self.response = @res.body
        else
          # bad request
          self.status = 400
        end
        
        self.save ? self : false
      end

  end
end
