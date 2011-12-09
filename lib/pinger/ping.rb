module Pinger
  class Ping < Sequel::Model
    
    many_to_one :domain
    
    plugin :timestamps
    
  end
end
