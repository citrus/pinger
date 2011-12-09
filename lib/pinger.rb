require "rubygems"
require "sequel"
require "pinger/version"

module Pinger
  class Pinger::DatabaseError < StandardError; end
  
  class << self
    
    def connection
      begin
        @connection ||= if ENV["PINGER_DB"].nil?
          Sequel.sqlite
        else
          Sequel.connect ENV["PINGER_DB"]
        end
      rescue Exception => e
        puts "*" * 88
        puts "Error while connecting to database"
        puts e.message
        puts "*" * 88
      end
    end
    alias :db :connection
    
    def connect
      raise Pinger::DatabaseError if connection.nil?
    end
    
    def create_schema
      
      unless db.table_exists?(:domains)
        db.create_table :domains do
          primary_key :id
          String      :domain, :unique => true, :null => false
          DateTime    :created_at
          index       :created_at
        end        
      end
      
      unless db.table_exists?(:pings)
        db.create_table :pings do
          primary_key :id
          foreign_key :domain_id, :domains, :key => :id
          String      :status
          column      :response, :text
          DateTime    :created_at
          index       :created_at
        end
      end
      
    end
        
    def init!
      connect
      create_schema
    end
    
  end
  
end

Pinger.init!

require "pinger/domain"
require "pinger/ping"
