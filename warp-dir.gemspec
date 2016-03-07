# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'warp/dir/version'

Gem::Specification.new do |gem|
  gem.name          = 'warp-dir'
  gem.license       = 'MIT'
  gem.authors       = ['Konstantin Gredeskoul']
  gem.email         = ['kig@reinvent.one']
  gem.version       = Warp::Dir::VERSION

  gem.summary       = %q{Warp Directory: this is drop in replacement of the 'wd' tool available on ZSH. Written in ruby, it is available for any shell.}
  gem.description   = %q{ZSH has a very nifty tool called 'wd' for Warp Directory (https://github.com/mfaerevaag/wd). Unfortunately it only works with ZSH.}
  gem.homepage      = "https://github.com/kigster/warp-dir"

  gem.files         = `git ls-files`.split($\).reject{ |f| f =~ /^doc\// }
  gem.executables   << 'warp-dir'

  gem.post_install_message =<<-EOF

PLEASE NOTE:

For this gem to work, you must also install the coupled shell function
into your ~/.bashrc file (or any other shell initialization file). The
following command should complete the setup.

  gem install warp-dir --no-wrappers --force
  warp-dir install --

Thank you!

  EOF

  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.require_paths = ["lib"]

  gem.add_dependency('slop', '~> 4.2')
  gem.add_dependency('colored', '~> 1')

  gem.add_development_dependency 'codeclimate-test-reporter', '~> 0.5'
  gem.add_development_dependency 'bundler', '~> 1.11'
  gem.add_development_dependency 'rake', '~> 10.0'
  gem.add_development_dependency 'rspec', '~> 3.4'
end
