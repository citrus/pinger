# encoding: UTF-8
require "bundler/gem_tasks"
require "rake/testtask"

Rake::TestTask.new do |t|
  t.pattern = "test/*_test.rb"
  t.libs += %w(lib test)
end

desc "Tests against database configurations defined in .db_urls"
task :test_adapters do
  config = File.expand_path("../.db_urls", __FILE__)
  if File.exists?(config)
    adapters = File.read(config).split("\n").compact
    if adapters.empty?
      puts "Please define database urls in .db_urls seperated by new lines. For Example:"
      puts "-" * 78
      puts "sqlite://test/db/pinger_test.db"
      puts "postgres://root:@localhost/pinger_test"
      puts "mysql2://root:@localhost/pinger_test"
    else
      puts "Testing against:"
      puts "- #{adapters.join("\n- ")}"
      adapters.each do |i|
        puts "\n" + ("=" * 78)
        puts "Testing with database #{i}"
        puts "-" * 78
        ENV["PINGER_TEST_DB"] = i
        Rake::Task["test"].execute
      end
    end
  else
    puts ".db_urls config was not found in #{File.dirname(config)}"
  end
end

task :default => [ :test ]
