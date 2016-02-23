require 'spec_helper'
require 'warp/dir'
require 'warp/dir/config'
require 'warp/dir/point'
require 'warp/dir/store'

module Warp
  module Dir
    describe Point do
      let(:config) { Config.new(config: file.path) }
      let(:fake_serializer) {
        FakeSerializer ||= Class.new(Warp::Dir::Serializer::Base) do
          def persist!; end
          def restore!; end
        end
      }
      let(:store) { Store.new(Config.new, :fake_serializer) }
      let(:path_absolute) { ENV['HOME'] + '/workspace' }
      let(:path_relative) { '~/workspace' }
      let(:p1) { Point.new('p', ENV['HOME'] + '/workspace') }

      describe 'when another identical point is created' do
        let(:p2) { Point.new('p', ENV['HOME'] + '/workspace') }
        it 'properly responds to eql? and to_hash' do
          expect(p1).to eql(p2)
          expect(p1.hash).to eql(p2.hash)
        end
      end
    end
  end
end
