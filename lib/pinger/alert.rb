module Pinger
  class Alert < Sequel::Model
    
    many_to_one :uri, :class => URI
    many_to_one :ping
    
  end
end
