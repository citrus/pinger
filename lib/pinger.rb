require "sequel"
require "pinger/version"
require "pinger/formatted_time"
require "pinger/batch"

module Pinger
  class Pinger::DatabaseError < StandardError; end
  
  class << self
    
    def connection
      return @connection if @connection
      begin
        @connection = Sequel.connect ENV["PINGER_DB"]
      rescue Exception => e
        puts "*" * 88
        puts "Error while connecting to database"
        puts e.message
        puts "*" * 88
      end
      @connection
    end
    alias :db :connection
    
    def connect
      raise Pinger::DatabaseError if connection.nil?
    end
    
    def create_schema
      
      unless db.table_exists?(:uris)
        db.create_table :uris do
          primary_key :id
          String      :uri, :unique => true, :null => false
          String      :scheme
          String      :user_info
          String      :host
          Integer     :port
          String      :registry
          String      :path
          String      :opaque
          String      :query
          String      :fragment
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
          DateTime    :created_at
          index       :created_at
        end
      end
      
    end
    
    def reset_database!
      db.drop_table(:pings, :uris)
      create_schema
    end
    
    def require_models
      require "pinger/uri"
      require "pinger/ping"
    end
      
    def init!
      connect
      create_schema
      require_models
    end
    
  end
  
end

Pinger.init!
