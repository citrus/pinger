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
        uri = URI.parse(domain.url)
        res = Net::HTTP.get_response(uri)
        #puts res.inspect
        self.status = res.code
        self.response = res.body
        self.response_time = (Time.now.to_f - time).round(3)
        self.save ? self : false
      end

  end
end

