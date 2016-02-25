require 'codeclimate-test-reporter'
require 'warp/dir'
require 'rspec/core'
CodeClimate::TestReporter.start

RSpec.configure do |config|
end

RSpec.shared_context :store_can_be_recreated do
  module Warp
    module Dir
      class Store
        class << self
          # Here we cheat and give us the ability to create new Stores.
          def create(*args, &block)
            new(*args, &block)
          end
        end
      end
    end
  end
end

RSpec.shared_context :fake_serializer do
  include_context :store_can_be_recreated
  let(:file) { @file ||= ::Tempfile.new('warp-dir') }
  let(:config) { Warp::Dir::Config.new(config: file.path) }
  let(:fake_serializer) {
    @fake_serializer ||= FakeSerializer ||= Class.new(Warp::Dir::Serializer::Base) do
      def persist!;
      end

      def restore!;
      end
    end
  }
  let(:store) {
    Warp::Dir::Store.create(config, @fake_serializer)
  }
  let(:wp_path) { ENV['HOME'] + '/workspace/tinker-mania' }
  let(:wp_name) { 'harro' }
  let(:point) { Warp::Dir::Point.new(wp_name, wp_path) }
end
