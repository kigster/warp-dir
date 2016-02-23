require 'spec_helper'
require 'warp/dir'
require 'warp/dir/config'
require 'warp/dir/store'
require 'tempfile'
module Warp
  module Dir
    describe Store do
      let(:file) { @file ||= ::Tempfile.new('warp-dir') }
      let(:config) { Config.new(config: file.path) }
      let(:store) { Store.new(config) }
      after :each do
        file.close
        file.unlink
      end

      context 'when config file is empty' do
        let(:point_name) { 'moo' }
        let(:point_path) { ENV['HOME'] + '/tmp/12398485' }

        it 'should be able to initialize the Store' do
          expect(store.points).to be_empty
        end

        it 'should be able to add a new point to the Store' do
          store.add(point_name, point_path)
          corrected_path = Warp::Dir.relative point_path
          expect(store[point_name].path).to eql(corrected_path)
        end

        it 'should not be able to add a different point with the same name' do
          store.add(point_name, point_path)
          # double adding the same point is ok
          expect{store.add(point_name, point_path)}.to_not raise_error
          # adding another point pointing to the same name is not OK
          expect{store.add(point_name, point_path + "98984")}.to raise_error(Warp::Dir::Errors::PointAlreadyExists)
        end

        it 'should be able to add multiple points to the Store' do
          store.add('m1', '123')
          store.add('m2', '456')
          expect(store['m1'].path).to eql('123')
          expect(store.path('m2')).to eql('456')
        end

      end

      context 'existing config file' do
        before do
          store.add('m1', 'A1')
          store.add('m2', 'A2')
          store.save!
        end

        describe 'restoring from persintence' do
          let(:new_store) { Store.new(config) }

          it 'should be able to restore the points at a later time' do
            expect(new_store.path('m1')).to eql('A1')
            expect(new_store['m2'].path).to eql('A2')
          end

          it 'should not allow overwriting without a force flag' do
            # adding another point pointing to the same name is not OK
            expect{new_store.add('m1', '98984')}.to raise_error(Warp::Dir::Errors::PointAlreadyExists)
          end

          it 'should be able to find the point' do
            expect(new_store['m1']).to eql(Point.new('m1', 'A1'))
          end

          it 'should NOT be able to find a non-existent point' do
            expect(new_store['ASDSADAS']).to be_nil
          end
        end
      end
    end
  end
end
