require 'pinger'

module Pinger

  module CLI
  
    UTILITY_COMMANDS = %w(list stats help)
    DOMAIN_COMMANDS  = %w(add rm show ping) 
    COMMANDS         = UTILITY_COMMANDS + DOMAIN_COMMANDS
 
    def self.run(command, args)
      command = :help unless COMMANDS.include?(command)      
      return usage(command) if args.length != 1 && DOMAIN_COMMANDS.include?(command)
      puts Commands.send(command, *args)
    end

    def self.usage(command)
      puts "Usage: pinger #{command} DOMAIN"
    end
       
    module Commands
          
      extend self

      def stats
        "#{Pinger::Ping.count} pings on #{Pinger::Domain.count} domains"     
      end

      def list
        info = []
        Pinger::Domain.dataset.each do |i|
          info << i.domain
        end
        info << "No domains have been added to pinger. Add a domain with `pinger add DOMAIN`" if info.empty?
        info.join("\n")
      end
       
      def add(domain=nil)
        return "#{domain} already exists in pinger" if find_domain(domain) 
        record = Pinger::Domain.new(:domain => domain)
        if record.save
          "#{domain} was successfully added to pinger"
        else
          "#{domain} could not be added to pinger"
        end 
      end
      
      def rm(domain=nil)
        if record = Pinger::Domain.find(:domain => domain)
          if record.destroy
            "#{domain} was successfully removed from pinger"
          else
            "#{domain} could not be removed from pinger"
          end
        else     
          "#{domain} doesn't exist in pinger"
        end

      end
      
      def ping(domain=nil)
        record = find_domain(domain)
        return domain_not_found(domain) if record.nil?
        puts "pinging #{domain}..."
        ping = Pinger::Ping.create(:domain => record)
        ping.request!
        "finished in #{ping.response_time} seconds with status #{ping.status}"
      end
      
      def show(domain=nil)
	      record = find_domain(domain)
        return domain_not_found(domain) if record.nil?
        out = <<OUT
#{domain}
#{'=' * (domain.length + 3)}
#{record.pings.count} pings since #{record.created_at.formatted}
#{'-' * 40}
OUT
        out << record.pings.reverse.map{ |ping|
          [ ping.created_at.formatted, ping.status, "#{ping.response_time}s"  ].join(", ")
        }.join("\n")
        out
      end
 
      def self.help
        out = <<HELP
Welcome to pinger! Here's the rundown:

  pinger list          # Lists all domains in pinger's database
  pinger add DOMAIN    # Add a domain to pinger's database
  pinger remove DOMAIN # Remove the domain from pinger's database
  pinger ping DOMAIN   # Test the domain
  pinger show DOMAIN   # Show details for a domain
        
HELP
      end
      
      private

        def find_domain(domain)
          Pinger::Domain.find(:domain => domain)         
        end
        
        def domain_not_found(domain)
         "#{domain} hasn't been added to pinger. Add it with `pinger add #{domain}`"
        end

    end
    
  end

end
