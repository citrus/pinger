module Pinger
  class Alert < Sequel::Model
    
    many_to_one :ping
    
    def after_create
      notify
      super
    end
    
    def uri
      self.ping.uri rescue nil
    end
    
    def notify
      mail = Mail.new do
        to   Pinger.config["email_to"]
        from Pinger.config["email_from"]
      end
      mail[:subject] = self.subject
      mail[:body]    = self.ping.summary
      mail.deliver!
    end
    
  end
end
