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
    
    def type
      values[:type].to_sym unless values[:type].nil?
    end
    
    private
    
      def notify
        mail = Mail.new do
          to   Pinger.config[:email_to]
          from Pinger.config[:email_from]
        end
        mail[:subject] = [ uri.uri, self.subject ].join(" - ")
        mail[:body]    = self.ping.summary
        puts "#{FormattedTime.new.formatted} - mail sent to #{mail.to.join(", ")}" if mail.deliver!
      end
      
  end
end
