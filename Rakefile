
require 'bundler'
require 'rake/clean'

begin
  require 'rspec/core/rake_task'
rescue LoadError
  raise
end

include Rake::DSL

Bundler::GemHelper.install_tasks

RSpec::Core::RakeTask.new do |t|
  # Put spec opts in a file named .rspec in root
end

task :default => [:spec ]

