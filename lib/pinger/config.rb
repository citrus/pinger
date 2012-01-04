require "erb"
require "yaml"

module Pinger
  class Config < Hash
    
    attr_reader :hash, :path
    
    def self.defaults
      {
        :database_url                     => "sqlite://pinger.db",
        :template_path                    => File.expand_path("../templates", __FILE__),
        :email_to                         => "pinger.alert@example.com",
        :email_from                       => "pinger@example.com",
        :deliver_alerts                   => true,
        :delivery_method                  => :sendmail,
        :delivery_method_options          => {},
        :allowed_response_time_difference => 2,
        :allowed_response_size_difference => 1024
      }
    end
    
    def initialize(_path)
      @path = _path
      if !@path.nil? && File.exists?(path)
        read_yaml
      else
        raise Pinger::ConfigError, "Could not find config file at #{path}"
      end
      configure_mail
      self
    end
    
    def []=(key, value)
      store(key.to_sym, value)
    end
    
    def [](key)
      fetch(key.to_sym)
    end
    
    private
    
      # Stolen from rails 
      def symbolize_keys(hash)
        hash.inject({}){|result, (key, value)|
          new_key   = case key  
                      when String then key.to_sym  
                      else key  
                      end  
          new_value = case value
                      when Hash then symbolize_keys(value)
                      else value
                      end  
          result[new_key] = new_value  
          result
        }
      end
            
      def read_yaml
        loaded = YAML::load(ERB.new(IO.read(path)).result)
        loaded.reject!{|k, v| v.nil? || v.to_s.length == 0 }
        merge! symbolize_keys(Pinger::Config.defaults.merge(loaded))
      end
    
      def configure_mail
        options = [ fetch(:delivery_method), fetch(:delivery_method_options) ]
        Mail.defaults do
        	delivery_method *options
        end
      end
      
  end
end
