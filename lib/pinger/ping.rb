require "net/http"
require "uri"

module Pinger
  class Ping < Sequel::Model
    
    many_to_one :uri, :class => URI
    one_to_many :alerts, :key => "ping_id"
    
    plugin :association_dependencies, :alerts => :destroy
    plugin :timestamps
    
    def self.average_response_time(uri=nil)
      ds = uri.nil? ? self : uri.pings_dataset
      return 0 if ds.empty?
      ds.sum(:response_time) / ds.count
    end

    def self.average_response_size(uri=nil)
      ds = uri.nil? ? self : uri.pings_dataset
      return 0 if ds.empty?
      ds.sum(:response_size) / ds.count
    end

    def self.average_response_size_kb(uri=nil)
      (average_response_size(uri) / 1024.0).round(3)
    end

    def request!
      perform_request
      compare_to_previous if previous_ping
    end
    
    def stats
      [ created_at.formatted, status, "#{response_time}s", "#{response_size_kb}kb" ].join(", ")
    end
    
    def created_at
      t = values[:created_at]
      FormattedTime.at(t) unless t.nil?
    end
    
    def summary
      "#{created_at.formatted} - #{uri.uri} downloaded #{response_size_kb}kb in #{response_time} seconds with status #{status}"
    end
    
    def compare_to_previous
      alert!(:status) if status_changed?
      alert!(:response_time) if Pinger.config[:allowed_response_time_difference].to_f < response_time_difference
      alert!(:response_size) if Pinger.config[:allowed_response_size_difference].to_f < response_size_difference
    end
    
    def previous_ping
      @previous_ping ||= Pinger::Ping.order(:id).limit(1).where("uri_id = #{self.uri_id} AND id < #{self.id}").last
    end

    def alert!(type)
      alert = Pinger::Alert.create(:ping => self, :type => type)
      alert.build_against(previous_ping)
      alert.deliver! if Pinger.config[:deliver_alerts]
      alert
    end
    
    def status_changed?
      self.status != previous_ping.status
    end
    
    def response_time_difference
      return 0 unless previous_ping
      @response_time_difference ||= (previous_ping.response_time - response_time).abs
    end
    
    def response_size_difference
      return 0 unless previous_ping
      @response_size_difference ||= (previous_ping.response_size - response_size).abs
    end
    
    def response_size_difference_kb
      (response_size_difference / 1024.0).round(3)
    end
    
    def response_size_kb
      (response_size / 1024.0).round(3)
    end
    
    def to_param
      id
    end
    
    private
    
      def http_request
        return @http_request if @http_request
        @http_request = Net::HTTP::Get.new uri.request_uri
        @http_request["Cache-Control"] = "no-cache"
        @http_request["User-Agent"]    = "Pinger v#{Pinger::VERSION}"
        @http_request
      end
    
      def perform_request
        time = Time.now.to_f
        begin
          Net::HTTP.start(uri.host, uri.port, :use_ssl => uri.scheme == 'https') do |http|
            @response = http.request(http_request)
          end
        rescue Exception => e
          # bad request...
        end
        
        self.response_time = (Time.now.to_f - time).round(3)
        
        unless @response.nil?
          self.status        = @response.code.to_i
          self.response      = @response.body
          self.response_size = @response.body.bytesize
        else
          # bad request
          self.status = 400
        end
        
        self.save ? self : false
      end

  end
end
