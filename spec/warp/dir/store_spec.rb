require 'spec_helper'
require 'warp/dir'
require 'warp/dir/config'
require 'warp/dir/store'
require 'tempfile'

RSpec.describe Warp::Dir::Store do

  describe 'when warprc file does not yet exist' do
    let(:config_path) { "/tmp/warprc#{srand()}" }
    let(:config) { Warp::Dir::Config.new(warprc: config_path) }
    let(:store) { Warp::Dir::Store.new(config) }

    after do
      File.unlink(config_path) if File.exists?(config_path)
    end

    it 'does not fail for find requests' do
      expect(File.exist?(config.warprc)).to be_falsey, config.warprc
      expect { store['mypoint'] }.to raise_error(Warp::Dir::Errors::PointNotFound)
    end

    it 'creates the file when adding points' do
      expect(File.exist?(config.warprc)).to be_falsey, config.warprc
      expect(store.size).to eql(0)
      store.add(point_name: 'mypoint', point_path: '/tmp')
      expect(File.exist?(config.warprc)).to be_falsey, config.warprc
    end
  end

  describe 'when warprc file already exists' do
    include_context :fake_serializer
    include_context :initialized_store

    context 'when store responds to common methods on collections' do
      let(:point_name) { 'moo' }
      let(:point_path) { ENV['HOME'] + '/tmp/12398485' }
      let(:store) { Warp::Dir::Store.new(config) }
      let(:p1) { Warp::Dir::Point.new('p', ENV['HOME'] + '/workspace') }
      let(:p2) { Warp::Dir::Point.new('n', ENV['HOME'] + '/workspace/new-project') }

      it 'should be able to have an empty store' do
        expect(store.points).to be_empty
      end

      it 'should respond to #size and return 0' do
        expect(store.size).to eql(0)
      end

      it 'it should respond to #<< and add a new point' do
        store.add(point: p1)
        store.add(point: p2)
        store << Warp::Dir::Point.new('123', '436')
        expect(store.size).to eql(3)
      end
    end

    context 'when the data store is empty' do
      let(:point_name) { 'moo' }
      let(:point_path) { ENV['HOME'] + '/tmp/12398485' }
      let(:store) { Warp::Dir::Store.new(config) }

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
        store.add(point_name: point_name, point_path: point_path)
        corrected_path = Warp::Dir.absolute point_path
        expect(store[point_name].path).to eql(corrected_path)
      end

      it 'should not be able to add a different point with the same name' do
        store.add(point_name: point_name, point_path: point_path)
        # double adding the same point is ok
        expect { store.add(point_name: point_name, point_path: point_path) }.to_not raise_error
        # adding another point pointing to the same name is not OK
        expect { store.add(point_name: point_name, point_path: point_path + '98984') }.to raise_error(Warp::Dir::Errors::PointAlreadyExists)
      end

      it 'should be able to add multiple points to the Store' do
        store.add(point_name: 'm1', point_path: '123')
        store.add(point_name: 'm2', point_path: '456')
        expect(store['m1'].path).to eql('123')
        expect(store['m2'].path).to eql('456')
      end
    end

    context 'data store contains some warp points already' do
      let(:store) { Warp::Dir::Store.new(config) }
      before do
        store.add(point_name: 'm1', point_path: 'A1')
        store.add(point_name: 'm2', point_path: 'A2')
        store.save!
      end

      describe 'reading data' do
        let(:new_store) { Warp::Dir::Store.new(config) }

        it 'should restore correctly compared to last saved' do
          expect(new_store['m1'].path).to eql('A1')
          expect(new_store['m2'].path).to eql('A2')
        end

        it 'should not allow overwriting without a force flag' do
          # adding another point pointing to the same name is not OK
          expect { new_store.add(point_name: 'm1', point_path: '98984') }.to raise_error(Warp::Dir::Errors::PointAlreadyExists)
        end

        it 'should be able to find previously saved item' do
          expect(new_store['m1']).to eql(Warp::Dir::Point.new('m1', 'A1'))
        end

        it 'should be able to handle when it doesnt find a given element' do
          expect { new_store['ASDSADAS'] }.to raise_error(Warp::Dir::Errors::PointNotFound)
        end
      end
    end
  end
end
