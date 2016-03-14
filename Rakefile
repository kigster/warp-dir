task :install do

  [ %q(chmod -R o+r .),
    %q(rm -f *.gem),
    %q(rm -rf build),
    %q(gem uninstall -quiet -a --executables warp-dir 2> /dev/null; true),
    %q(gem build warp-dir.gemspec)
  ].each do |command|
    sh command
  end

  sh <<-EOF.gsub(%r{^\s+}m, '')
    export gem_file=$(ls -1 *.gem | tail -1)
    export gem_name=${gem_file//.gem/}
    if [ "$(which ruby)" == "/usr/bin/ruby" ]; then
      gem install $gem_file -n /usr/local/bin --no-ri --no-rdoc
    else
      gem install $gem_file --no-ri --no-rdoc
    fi
  EOF
end

desc 'Install development dependencies for this gem'
task :deps do
  sh %q{
    echo "source 'https://rubygems.org'; gemspec" > Gemfile
    [[ -n $(which bundle) ]] || gem install bundler --no-ri --no-rdoc
    bundle install
    rm -f Gemfile
  }
end

require 'rake/clean'
CLEAN.include %w(pkg coverage *.gem)

begin
  require 'rspec/core/rake_task'
  RSpec::Core::RakeTask.new(:spec)
rescue LoadError
end

task :default => [:spec]
