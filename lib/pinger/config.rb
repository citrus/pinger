require "erb"
require "yaml"

module Pinger
  class Config < Hash
    
    attr_reader :hash, :path
    
    def self.defaults
      {
        "email_from" => "pinger@example.com"
      }
    end
    
    def initialize(_path)
      @path = _path
      if File.exists?(path)
        merge! Pinger::Config.defaults.merge(YAML::load(ERB.new(IO.read(path)).result))
      else
        raise Pinger::ConfigError, "Could not find config file at #{path}"
      end
      self
    end
      
  end
end
