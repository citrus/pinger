require "shoulda"
require "capybara/rails"

Capybara.default_driver   = :selenium
Capybara.default_selector = :css

# Load support files
Dir["#{File.dirname(__FILE__)}/support/**/*.rb"].each { |f| require f }