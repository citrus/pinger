require "erb"
require "yaml"

module Pinger
  class Config < Hash
    
    attr_reader :hash, :path
    
    def self.defaults
      {
        "database_url"            => "sqlite://pinger.db",
        "email_to"                => "pinger.alert@example.com",
        "email_from"              => "pinger@example.com",
        "delivery_method"         => :sendmail,
        "delivery_method_options" => {}
      }
    end
    
    def initialize(_path)
      @path = _path
      if File.exists?(path)
        read_yaml
      else
        raise Pinger::ConfigError, "Could not find config file at #{path}"
      end
      configure_mail
      self
    end
    
    private
    
      def read_yaml
        loaded = YAML::load(ERB.new(IO.read(path)).result)
        loaded.reject!{|k, v| v.nil? || v.to_s.length == 0 }
        merge! Pinger::Config.defaults.merge(loaded)
      end
    
      def configure_mail
        options = [ fetch("delivery_method"), fetch("delivery_method_options") ]
        Mail.defaults do
        	delivery_method *options
        end
      end
      
  end
end
