require "codeclimate-test-reporter"
require 'warp/dir'
require 'rspec/core'
CodeClimate::TestReporter.start

RSpec.configure do |config|
end

RSpec.shared_context 'fake_serializer' do
  let(:file) { @file ||= ::Tempfile.new('warp-dir') }
  let(:config) { Warp::Dir::Config.new(config: file.path) }
  let(:fake_serializer) {
    FakeSerializer ||= Class.new(Warp::Dir::Serializer::Base) do
      def persist!;
      end

      def restore!;
      end
    end
  }
  let(:store) { Warp::Dir::Store.new(Warp::Dir::Config.new, fake_serializer) }
  let(:wp_path) { ENV['HOME'] + '/workspace/tinker-mania' }
  let(:wp_name) { 'harro' }
  let(:point) { Warp::Dir::Point.new(wp_name, wp_path) }
end
