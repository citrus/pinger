module Pinger
  class URI < Sequel::Model
    
    one_to_many :pings
    
    plugin :association_dependencies, :pings => :destroy
    plugin :timestamps

    def created_at
      values[:created_at].extend(FormattedTime)
    end 

  end
end
