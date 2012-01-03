require "erb"
require "yaml"

module Pinger
  class Config < Hash
    
    attr_reader :hash, :path
    
    def self.defaults
      {
        "database_url" => "sqlite://pinger.db",
        "email_to"     => "pinger.alert@example.com",
        "email_from"   => "pinger@example.com"
      }
    end
    
    def initialize(_path)
      @path = _path
      if File.exists?(path)
        loaded = YAML::load(ERB.new(IO.read(path)).result)
        loaded.reject!{|k, v| v.nil? || v.to_s.length == 0 }
        merge! Pinger::Config.defaults.merge(loaded)
      else
        raise Pinger::ConfigError, "Could not find config file at #{path}"
      end
      self
    end
      
  end
end
