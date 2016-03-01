require 'spec_helper'
require 'warp/dir'
require 'warp/dir/config'
require 'warp/dir/store'
require 'tempfile'
module Warp
  module Dir
    describe Store do
      include_context :fake_serializer

      context 'when store responds to common methods on collections' do
        let(:point_name) { 'moo' }
        let(:point_path) { ENV['HOME'] + '/tmp/12398485' }
        let(:store) { Store.create(config) }
        let(:p1) { Warp::Dir::Point.new('p', ENV['HOME'] + '/workspace') }
        let(:p2) { Warp::Dir::Point.new('n', ENV['HOME'] + '/workspace/new-project') }

        it 'should be able to have an empty store' do
          expect(store.points).to be_empty
        end

        it 'should respond to #size and return 0' do
          expect(store.size).to eql(0)
        end

        it 'it should respond to #<< and add a new point' do
          store.add(p1)
          store.add(p2)
          store << Warp::Dir::Point.new('123', '436')
          expect(store.size).to eql(3)
        end
      end

      context 'when the data storeis empty' do
        let(:point_name) { 'moo' }
        let(:point_path) { ENV['HOME'] + '/tmp/12398485' }
        let(:store) { Store.create(config) }

        it 'should be able to initialize the Store' do
          expect(store.points).to be_empty
        end

        it 'should respond to #size and return 0' do
          expect(store.size).to eql(0)
        end

        it 'it should respond to #<< and add a new point' do
          expect(store.size).to eql(0)
          store << Warp::Dir::Point.new('123', '436')
          expect(store.size).to eql(1)
        end

        it 'should be able to add a new point to the Store' do
          store.add_by_name(point_name, point_path)
          corrected_path = Warp::Dir.absolute point_path
          expect(store[point_name].path).to eql(corrected_path)
        end

        it 'should not be able to add a different point with the same name' do
          store.add_by_name(point_name, point_path)
          # double adding the same point is ok
          expect { store.add_by_name(point_name, point_path) }.to_not raise_error
          # adding another point pointing to the same name is not OK
          expect { store.add_by_name(point_name, point_path + '98984') }.to raise_error(Warp::Dir::Errors::PointAlreadyExists)
        end

        it 'should be able to add multiple points to the Store' do
          store.add_by_name('m1', '123')
          store.add_by_name('m2', '456')
          expect(store['m1'].path).to eql('123')
          expect(store['m2'].path).to eql('456')
        end
      end

      context 'data store contains some warp points already' do
        let(:store) { Store.create(config) }
        before do
          store.add_by_name('m1', 'A1')
          store.add_by_name('m2', 'A2')
          store.save!
        end

        describe 'reading data' do
          let(:new_store) { Store.create(config) }

          it 'should restore correctly compared to last saved' do
            expect(new_store['m1'].path).to eql('A1')
            expect(new_store['m2'].path).to eql('A2')
          end

          it 'should not allow overwriting without a force flag' do
            # adding another point pointing to the same name is not OK
            expect { new_store.add_by_name('m1', '98984') }.to raise_error(Warp::Dir::Errors::PointAlreadyExists)
          end

          it 'should be able to find previously saved item' do
            expect(new_store['m1']).to eql(Point.new('m1', 'A1'))
          end

          it 'should be able to handle when it doesnt find a given element' do
            expect{ new_store['ASDSADAS']}.to raise_error(Warp::Dir::Errors::PointNotFound)
          end
        end
      end
    end
  end
end
