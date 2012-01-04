require "sequel"
require "mail"

require "pinger/version"
require "pinger/formatted_time"
require "pinger/config"
require "pinger/batch"

module Pinger

  class DatabaseError < StandardError; end
  class ConfigError   < StandardError; end
   
  class << self
    
    def connection
      return @connection if @connection
      begin
        @connection = Sequel.connect(config[:database_url])
      rescue Exception => e
        puts "*" * 88
        puts "Error while connecting to database"
        puts e.message
        puts "*" * 88
      end
      @connection
    end
    alias :db :connection
    
    def config
      @config ||= Pinger::Config.new(config_path)
    end
    
    def config_path
      @config_path ||= ENV["PINGER_CONFIG"] || File.expand_path("~/.pinger.yml")
    end
    
    def connect
      raise Pinger::DatabaseError if connection.nil?
    end
    
    def create_schema
      
      unless db.table_exists?(:uris)
        db.create_table :uris do
          primary_key :id
          String      :uri, :unique => true, :null => false
          String      :scheme
          String      :userinfo
          String      :host
          Integer     :port
          String      :registry
          String      :path
          String      :opaque
          String      :query
          String      :fragment
          String      :request_uri
          DateTime    :created_at
          index       :created_at
        end
      end
      
      unless db.table_exists?(:pings)
        db.create_table :pings do
          primary_key :id
          foreign_key :uri_id, :uris, :key => :id
          Integer     :status
          column      :response, :text
          Float       :response_time
          Integer     :response_size       
          DateTime    :created_at
          index       :created_at
        end
      end
      
      unless db.table_exists?(:alerts)
        db.create_table :alerts do
          primary_key :id
          foreign_key :ping_id, :pings, :key => :id
          String      :subject
          DateTime    :created_at
          index       :created_at
        end
      end
      
    end
    
    def reset_database!
      db.drop_table(:alerts, :pings, :uris)
      create_schema
    end
    
    def require_models
      require "pinger/uri"
      require "pinger/ping"
      require "pinger/alert"
    end
      
    def init!
      config
      connect
      create_schema
      require_models
    end
    
  end
  
end

Pinger.init!
