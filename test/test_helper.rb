DB_PATH = File.expand_path("../db/pinger.db", __FILE__)
File.delete(DB_PATH) if File.exists?(DB_PATH)

ENV["PINGER_DB"] = "sqlite://#{DB_PATH}"

gem "minitest"
require "minitest/autorun"
require "minitest/should"
begin require "turn"; rescue LoadError; end

require "pinger"

# Load support files
Dir["#{File.dirname(__FILE__)}/support/**/*.rb"].each { |f| require f }
