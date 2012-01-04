require "erb"

module Pinger
  class Alert < Sequel::Model
        
    many_to_one :ping
    
    def uri
      self.ping.uri rescue nil
    end
    
    def type
      values[:type].to_sym unless values[:type].nil?
    end
    
    def build_against(previous_ping)
      self.subject = render_erb(:subject, previous_ping)
      self.message = render_erb(:message, previous_ping)
   	  self.save ? self : false
    end
    
    def deliver!
      mail = Mail.new do
        to   Pinger.config[:email_to]
        from Pinger.config[:email_from]
      end
      mail[:subject] = [ uri.uri, self.subject ].join(" - ")
      mail[:body]    = self.message
      puts "#{FormattedTime.new.formatted} - mail sent to #{mail.to.join(", ")}" if mail.deliver!
    end
    
    private
    
      def render_erb(dir, previous_ping)
        path = File.join(Pinger.config[:template_path], dir.to_s)
        template = File.join(path, "#{type}.erb")
        if File.exists?(template)
          ERB.new(File.read(template)).result(binding).strip
        else
          raise Pinger::TemplateNotFound, "Could not find #{type}.erb in #{path}"
        end
      end
    
  end
end
