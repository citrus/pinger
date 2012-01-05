require "erb"

module Pinger
  class Alert < Sequel::Model
    
    many_to_one :ping
    plugin :timestamps
    
    def created_at
      t = values[:created_at]
      FormattedTime.at(t) unless t.nil?
    end
    
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
        paths = [
          Pinger.config[:template_path],
          Pinger::Config.default_template_directory
        ]
        paths.uniq.each do |path|
          path = File.join(path, dir.to_s)
          @template = File.join(path, "#{type}.erb")
          if File.exists?(@template)
            @out = ERB.new(File.read(@template)).result(binding).strip
            break
          end
        end
        raise Pinger::TemplateNotFound, "Could not find #{type}.erb in paths:\n#{paths}" if @out.nil?
        @out
      end
    
  end
end
