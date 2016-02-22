require 'spec_helper'
require 'warp/dir'
require 'warp/dir/config'
require 'warp/dir/store'

module Warp
  module Dir
    describe Store do
      let(:dotfile) { @dotfile ||= Tempfile.new('warp-dir') }
      let(:config) { Config.new(dotfile: Tempfile.new.path) }
      let(:store) { Store.new(config) }
      after :each do
        dotfile.close
        dotfile.unlink
      end

      context 'starting with empty dotfile' do
        let(:point_name) { 'moo' }
        let(:point_path) { '/tmp/12398485' }
        it 'should be able to read empty file' do
          expect(store.points).to be_empty
        end
        it 'should be able to add a new point' do
          store.add(point_name, point_path)
          expect(store.points[point_name]).to eql(point_path)
        end
        it 'should be able to add multiple points' do
          store.add('m1', '123')
          store.add('m2', '456')
          expect(store.points['m1']).to eql('123')
          expect(store.points['m2']).to eql('456')
        end
      end

      context 'non-empty dotfile' do
        before do
          store.add!('m1', 'A1')
          store.add!('m2', 'A2')
        end

        it 'should be able to restore the points at a later time' do
          new_store = Store.new(config)
          expect(new_store.points['m1']).to eql('A1')
          expect(new_store.points['m2']).to eql('A2')
        end
      end
    end
  end
end
