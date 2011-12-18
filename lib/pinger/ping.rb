require 'net/http'
require 'uri'

module Pinger
  class Ping < Sequel::Model
    
    many_to_one :domain
    
    plugin :timestamps

    attr_reader :response_time

    def before_create
      perform_request
      super
    end

    private 

      def perform_request
        time = Time.now.to_f
        uri = URI.parse(domain.url)
        res = Net::HTTP.get_response(uri)
        #puts res.inspect
        self.status = res.code
        self.response = res.body
        @response_time = (Time.now.to_f - time).round(3)
      end

  end
end

