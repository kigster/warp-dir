# frozen_string_literal: true

lib = File.expand_path('lib', __dir__)
$:.unshift lib unless $:.include?(lib)
require 'warp/dir/version'

Gem::Specification.new do |s|
  s.name          = 'warp-dir'
  s.license       = 'MIT'
  s.authors       = ['Konstantin Gredeskoul']
  s.email         = ['kig@reinvent.one']
  s.version       = Warp::Dir::VERSION
  s.summary       = %q{Warp-Dir (aka 'wd') replaces 'cd' and lets you instantly move between saved "warp points" and regular folders.}
  s.description   = "Warp-Dir is compatible (and inspired by) the popular 'wd' tool available as a ZSH module. This one is written in ruby and so it should work in any shell. Credits for the original zsh-only tool go to (https://github.com/mfaerevaag/wd)."
  s.homepage      = 'https://github.com/kigster/warp-dir'
  s.files         = `git ls-files`.split($\).reject{ |f| f.match(%r{^(doc|spec)/}) }

  s.executables << 'warp-dir'
  s.bindir = 'exe'

  s.post_install_message = ::Warp::Dir::INSTALL_NOTICE
  s.require_paths = %w(lib)

  s.required_ruby_version     = '>= 2.3.0'
  s.required_rubygems_version = '>= 1.3.6'

  s.add_dependency('slop', '~> 4.2')

  s.add_development_dependency 'bundler'
  s.add_development_dependency 'rake'
  s.add_development_dependency 'rspec', '~> 3'
  s.add_development_dependency 'rspec-its'
  s.add_development_dependency 'rubocop'
  s.add_development_dependency 'rubocop-rspec'
  s.add_development_dependency 'rubocop-rake'
end
