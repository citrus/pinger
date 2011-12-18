ENV["PINGER_DB"] = "sqlite://test/db/pinger.db"

File.delete(ENV["PINGER_DB"]) if File.exists?(ENV["PINGER_DB"])

gem "minitest"
require "minitest/autorun"
require "minitest/should"
begin require "turn"; rescue LoadError; end

require "pinger"

# Load support files
Dir["#{File.dirname(__FILE__)}/support/**/*.rb"].each { |f| require f }
