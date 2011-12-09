gem "minitest"
require "minitest/autorun"
require "minitest/should"

require "pinger"

# Load support files
Dir["#{File.dirname(__FILE__)}/support/**/*.rb"].each { |f| require f }
