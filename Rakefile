# encoding: UTF-8
require "bundler/gem_tasks"
require "rake/testtask"

Rake::TestTask.new do |t|
  t.pattern = "test/*_test.rb"
  t.libs += %w(lib test)
end

task :default => [ :test ]
