require 'net/http'
require 'uri'

module Pinger
  class Ping < Sequel::Model
    
    many_to_one :uri, :class => URI
    
    plugin :timestamps

    def request! 
      perform_request
    end
    
    def created_at
      t = values[:created_at]
      FormattedTime.at(t) unless t.nil?
    end

    private 

      def perform_request
        time = Time.now.to_f
        @uri = ::URI.parse(uri.uri)
        begin
          Net::HTTP.start(@uri.host, @uri.port, :use_ssl => @uri.scheme == 'https') do |http|
            request = Net::HTTP::Get.new @uri.request_uri
            @response = http.request(request)
          end
        rescue Exception => e
          # bad request...
        end
        
        self.response_time = (Time.now.to_f - time).round(3)
        
        unless @response.nil?
          self.status = @response.code.to_i
          self.response = @response.body
        else
          # bad request
          self.status = 400
        end
        
        self.save ? self : false
      end

  end
end
