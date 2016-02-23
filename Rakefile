
require 'bundler'
require "bundler/gem_tasks"
require 'rake/clean'
require 'rspec/core/rake_task'

task :default => [:rspec ]

namespace :gem do
  task :reinstall do
    sh <<-EOF
rm *.gem
rm -rf build
gem uninstall -a -x warp-dir          --verbose
gem build warp-dir.gemspec            --verbose
gem_file=$(ls -1 *.gem | tail -1)
gem_name=${gem_file//.gem/}
gem install $gem_file                 --verbose
    EOF
  end
end
