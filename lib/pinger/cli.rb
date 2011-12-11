require 'pinger'

module Pinger

  module CLI
  
    def self.commands
      %w(list add rm ping show)
    end
  
    def self.run(args)
      return help if args.empty?
      command = args.first
      raise "Invalid Command" unless Pinger::CLI.commands.include?(command)      
      return usage(command) unless args.length == 2 || command == "list" 
      Commands.send(*args)
    end

    def self.usage(command)
      puts "Usage: pinger #{command} DOMAIN"
    end
    
    def self.help
      puts <<HELP
Welcome to pinger! Here's the rundown:

Daemon:

  pinger start # Starts the pinger daemon
  pinger stop  # Stops the pinger daemon

Domains:

  pinger list          # Lists all domains in pinger's database
  pinger add DOMAIN    # Add a domain to pinger's database
  pinger remove DOMAIN # Remove the domain from pinger's database
  pinger ping DOMAIN   # Test the domain
  pinger show DOMAIN   # Show details for a domain
        
HELP
    end
    
    module Commands
          
      extend self
        
      def list
        info = []
        Pinger::Domain.dataset.each do |i|
          info << i.domain
        end
        info << "No domains have been added to pinger. Add a domain with `pinger add DOMAIN`" if info.empty?
        puts info.join("\n")
      end
       
      def add(domain=nil)
        if Pinger::Domain.find(:domain => domain)
          puts "#{domain} already exists in pinger"
        else     
          record = Pinger::Domain.new(:domain => domain)
          if record.save
            puts "#{domain} was successfully added to pinger"
          else
            puts "#{domain} could not be added to pinger"
          end
        end
      end
      
      def rm(domain=nil)
        if record = Pinger::Domain.find(:domain => domain)
          if record.destroy
            puts "#{domain} was successfully removed from pinger"
          else
            puts "#{domain} could not be removed from pinger"
          end
        else     
          puts "#{domain} doesn't exist in pinger"
        end

      end
      
      def ping(domain=nil)
        puts "ping ping bling bling"
      end
      
      def show(domain=nil)
        puts "show me #{domain}"
      end
    
    end
    
  end

end
