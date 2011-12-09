require "rubygems"
require "sequel"
require "pinger/version"

module Pinger
  class Pinger::DatabaseError < StandardError; end
  
  def self.connection
    begin
      @connection ||= if ENV["PINGER_DB"].nil?
        Sequel.sqlite
      else
        Sequel.connect ENV["PINGER_DB"]
      end
    rescue Exception => e
    end
  end
  
  def self.connect!
    raise Pinger::DatabaseError if connection.nil?
  end
  
end

Pinger.connect!

require "pinger/domain"
require "pinger/ping"
