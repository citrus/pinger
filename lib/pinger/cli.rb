require 'pinger'

module Pinger

  module CLI
  
    def self.commands
      %w(init add remove ping show).map(&:to_sym)
    end
  
    def self.run(args)
      return help if args.empty?
      command = (args.shift || "").to_sym
      puts "running #{command}"
      raise "Invalid Command" unless Pinger::CLI.commands.include?(command)
      Commands.send(command, args)
    end
    
    def self.help
      puts <<HELP
Welcome to pinger! Here's the rundown:

Daemon:

  pinger start # Starts the pinger daemon
  pinger stop  # Stops the pinger daemon

Domains:

  pinger add DOMAIN    # Add a domain to pinger's database
  pinger remove DOMAIN # Remove the domain from pinger's database
  pinger ping DOMAIN   # Test the domain
  pinger show DOMAIN   # Show details for a domain
        
HELP
    end
    
    module Commands
          
      extend self
          
      def init(args)
        Site.init!
      end
          
      def add(args)
        puts "add #{args.shift}"
        #site = Domain.new(args.shift, args)
        #saved = site.save
        #puts "Saved? #{saved}"
        #saved
      end
      
      def remove(args)
        puts "remove #{args.shift}"
      end
      
      def ping(args)
        puts "ping ping bling bling"
      end
      
      def show(args)
        puts "show me #{args.shift}"
      end
    
    end
    
  end

end