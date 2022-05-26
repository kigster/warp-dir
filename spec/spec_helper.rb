if RUBY_VERSION.to_f > 2.3
  require 'simplecov'
  SimpleCov.start
end

require 'warp/dir'
require 'rspec/core'
require 'rspec/its'

require 'support/cli_expectations'
require 'warp/dir/config'
require 'warp/dir/app/cli'
require 'pp'
require 'fileutils'

module Warp
  module Dir
    module App
      class Response
        class << self
          attr_accessor :exit_disabled

          def enable_exit!
            self.exit_disabled = false
          end

          def disable_exit!
            self.exit_disabled = true
          end

          def exit_disabled?
            self.exit_disabled
          end
        end
      end
    end
  end
end

RSpec.configure do |config|
  config.before do
    Warp::Dir::App::Response.disable_exit!
    srand 117
  end
end

RSpec.shared_context :fake_serializer do
  let(:file) { @file ||= ::Tempfile.new('warp-dir') }
  let(:config) { Warp::Dir::Config.new(warprc: file.path) }
  let(:serializer) {
    @initialized_store ||= FakeSerializer = Class.new(Warp::Dir::Serializer::Base) do
      def persist!;
      end

      def restore!;
      end
    end
  }

  after do
    file.close
    file.unlink
  end
end

RSpec.shared_context :fixture_file do
  let(:fixture_file) { 'spec/fixtures/warprc'}
  let(:warprc_args)  { " --config #{fixture_file}" }
  let(:config_path) { '/tmp/warprc' }
  let(:file) {
    FileUtils.cp(fixture_file, config_path)
    File.new(config_path)
  }
  let(:config) { Warp::Dir::Config.new(warprc: file.path) }
end

RSpec.shared_context :fixture_store do
  include_context :fixture_file
  let(:store) { Warp::Dir::Store.new(config) }
end

RSpec.shared_context :initialized_store do
  let(:store) { Warp::Dir::Store.new(config) }
  let(:wp_path) { "#{::Dir.home}/workspace/tinker-mania" }
  let(:wp_name) { 'harro' }
  let(:point) { Warp::Dir::Point.new(wp_name, wp_path) }
end
