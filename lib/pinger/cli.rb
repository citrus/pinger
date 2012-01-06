require "pinger"

module Pinger

  module CLI
  
    UTILITY_COMMANDS = %w(list stats batch flush config help)
    URI_COMMANDS     = %w(add rm show ping) 
    COMMANDS         = UTILITY_COMMANDS + URI_COMMANDS
 
    def self.run(*args)
      command = args.shift
      if URI_COMMANDS.include?(command)
        if args.length == 1
          uri = Pinger::URI.standardize(args.first)
          result = Commands.send(command, uri)
        else
          result = usage(command)
        end
      else
        command = :help unless COMMANDS.include?(command) && args.length == 0
        result = Commands.send(command)
      end
      result
    end

    def self.usage(command)
      "Usage: pinger #{command} URI"
    end
    
    module Commands
          
      extend self
      
      def list
        uris = Pinger::URI.order(:uri)
        return "No uris have been added to pinger. Add a uri with `pinger add URI`" if uris.empty?
        uris.map(:uri).join("\n")
      end
      
      def stats
        "#{Pinger::Ping.count} pings and #{Pinger::Alert.count} alerts on #{Pinger::URI.count} uris"     
      end

      def batch
        t = Time.now
        @batch = Batch.new
        @batch.process
        "#{@batch.uris.length} pings completed in #{(Time.now - t).round(3)} seconds"
      end
      
      def flush
        count1 = Pinger::Alert.count
        count2 = Pinger::Ping.count
        Pinger::Alert.dataset.destroy
        Pinger::Ping.dataset.destroy
        "deleted #{count1} alerts and #{count2} pings from pinger's database"
      end
      
      def config
        outs = [ "Pinger Configuration", "=" * 65 ]
        min = (Pinger.config.keys.sort_by(&:length).last.length + 3)
        Pinger.config.each do |k, v|
          diff = min - k.length
          outs << [ k, v ].join(" " * diff)
        end
        outs.join("\n")
      end

      def add(uri=nil)
        return "#{uri} already exists in pinger" if find_uri(uri) 
        record = Pinger::URI.new(:uri => uri)
        if record.save
          "#{record.uri} was successfully added to pinger"
        else
          "#{record.uri} could not be added to pinger"
        end 
      end
      
      def rm(uri=nil)
        if record = Pinger::URI.find(:uri => uri)
          record.destroy
          "#{uri} was successfully removed from pinger"
        else    
          "#{uri} doesn't exist in pinger"
        end
      end
      
      def ping(uri=nil)
        record = find_uri(uri)
        return uri_not_found(uri) if record.nil?
        ping = record.ping!
        ping.summary
      end
      
      def show(uri=nil)
	      record = find_uri(uri)
        return uri_not_found(uri) if record.nil?
        out = <<OUT
#{uri}
#{'=' * (uri.length + 3)}
#{record.pings.count} pings since #{record.created_at.formatted}
average: #{record.average_response_size}kb in #{record.average_response_time}s
#{'-' * 40}
OUT
        out << record.pings.reverse.map(&:stats).join("\n")
        out
      end
 
      def self.help
        out = <<HELP
Welcome to pinger! Here's the rundown:

  pinger help       # Shows pinger's usage
  pinger stats      # Shows stats for pings, alerts and uris
  pinger batch      # Runs a ping test for all uris in pinger's database
  pinger flush      # Deletes pings and alerts for all uris
  pinger config     # Displays pinger's current configuration
  pinger list       # Lists all uris in pinger's database
  
  pinger add URI    # Add a uri to pinger's database
  pinger rm URI     # Remove a uri from pinger's database
  pinger ping URI   # Run a ping test for a uri
  pinger show URI   # Show details for a uri

HELP
      end
      
      private

        def find_uri(uri)
          uri = Pinger::URI.standardize(uri)
          Pinger::URI.find(:uri => uri)         
        end
        
        def uri_not_found(uri)
         "#{uri} hasn't been added to pinger. Add it with `pinger add #{uri}`"
        end

    end
    
  end

end
