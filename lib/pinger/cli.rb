require 'pinger'

module Pinger

  module CLI
  
    def self.commands
      %w(add remove ping).map(&:to_sym)
    end
  
    def self.run(args)
      command = (args.shift || "").to_sym
      puts "running #{command}"
      raise "Invalid Command" unless Pinger::CLI.commands.include?(command)
      Commands.send(command, args)
    end
    
    module Commands
          
      extend self
          
      def add(args)
        puts "add #{args.shift}"
      end
      
      def remove(args)
        puts "remove #{args.shift}"
      end
      
      def ping(args)
        puts "ping ping bling bling"
      end
    
    end
    
  end

end