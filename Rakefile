# frozen_string_literal: true

require 'bundler/gem_tasks'
require 'rspec/core/rake_task'

require 'yard'

def shell(*args)
  puts "running: #{args.join(' ')}"
  system(args.join(' '))
end

task :permissions do
  shell('rm -rf pkg/ doc/')
  shell("chmod -v o+r,g+r * */* */*/* */*/*/* */*/*/*/* */*/*/*/*/*")
  shell("find . -type d -exec chmod o+x,g+x {} \\;")
end

task build: :permissions

YARD::Rake::YardocTask.new(:doc) do |t|
  t.files = %w(lib/**/*.rb exe/* - README.md LICENSE)
  t.options.unshift('--title', '"warp-dir", or "wd" (which stands for warp directory) is a Ruby implementation of the ZSH module by the same name, which is compatible with this gem. The `wd` command lets you "bookmark" and then "jump" to custom directories in BASH, without using cd. Why? Because cd seems inefficient when the folder is frequently visited or has a long path.')
  t.after = -> { exec('open doc/index.html') } if RUBY_PLATFORM =~ /darwin/
end

RSpec::Core::RakeTask.new(:spec)

task default: :spec
