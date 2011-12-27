module Pinger
  class URI < Sequel::Model
    
    one_to_many :pings
    
    plugin :association_dependencies, :pings => :destroy
    plugin :timestamps
  
    def self.standardize(uri)
      uri = "http://#{uri}" unless uri.to_s.match(/^https?:\/\//)
      uri
    end

    def before_create
      self.uri = Pinger::URI.standardize(uri)
      super
    end
    
    def created_at
      t = values[:created_at]
      FormattedTime.at(t) unless t.nil?
    end

  end
end
