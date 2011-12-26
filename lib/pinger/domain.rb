module Pinger
  class Domain < Sequel::Model
    
    one_to_many :pings
    
    plugin :association_dependencies, :pings => :destroy
    plugin :timestamps

    def url
      "http://#{domain}"
    end
    
    def created_at
      values[:created_at].extend(FormattedTime)
    end 

  end
end
