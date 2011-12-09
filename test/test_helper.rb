ENV["PINGER_DB"] = "sqlite://test/db/pinger.db"

gem "minitest"
require "minitest/autorun"
require "minitest/should"
begin require "turn"; rescue LoadError; end

require "pinger"

# Load support files
Dir["#{File.dirname(__FILE__)}/support/**/*.rb"].each { |f| require f }
