require "net/http"
require "uri"

module Pinger
  class Ping < Sequel::Model
    
    many_to_one :uri, :class => URI
    one_to_one  :alert, :key => "ping_id"
    
    plugin :association_dependencies, :alert => :destroy
    plugin :timestamps

    def request!
      perform_request
      compare_against(previous_ping) if previous_ping
    end
    
    def stats
      [ created_at.formatted, status, "#{response_time}s"  ].join(", ")
    end
    
    def created_at
      t = values[:created_at]
      FormattedTime.at(t) unless t.nil?
    end
    
    def summary
      "#{created_at.formatted} - #{uri.uri} finished in #{response_time} seconds with status #{status}"
    end
    
    def compare_against(ping)
      if self.status != ping.status
        alert!(:status, self.status, ping.status)
      end
    end
    
    def previous_ping
      @previous_ping ||= Pinger::Ping.order(:id).where("id < #{self.id}").last
    end

    def alert!(type, current, previous)
      subject = case type
        when :status
          "Status Changed from #{previous} to #{current}"
        else
          "Pinger Alert"
   	  end
   	  Pinger::Alert.create(:ping => self, :subject => subject)
    end
    
    private
    
      def perform_request
        time = Time.now.to_f
        begin
          Net::HTTP.start(uri.host, uri.port, :use_ssl => uri.scheme == 'https') do |http|
            request = Net::HTTP::Get.new uri.request_uri
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
