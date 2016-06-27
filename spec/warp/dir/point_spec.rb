require 'spec_helper'
require 'warp/dir'

RSpec.describe Warp::Dir::Point do
  include_context :fake_serializer
  include_context :initialized_store

  let(:path_absolute) { ENV['HOME'] + '/workspace' }
  let(:path_relative) { '~/workspace' }
  let(:p1) { Warp::Dir::Point.new('p', ENV['HOME'] + '/workspace') }
  let(:p2) { Warp::Dir::Point.new('n', ENV['HOME'] + '/workspace/new-project') }

  describe 'with two distinct but identical objects' do
    let(:p2) { Warp::Dir::Point.new('p', ENV['HOME'] + '/workspace') }
    it 'correctly defines #eql?' do
      expect(p1).to eql(p2)
    end
    it 'correctly defines #hash' do
      expect(p1.hash).to eql(p2.hash)
    end
    it '#file.path' do
      expect(file.path.length > 0).to be_truthy
    end
  end

  describe 'instance methods' do
    it '#to_s' do
      expect(p1.to_s).to eql('p  ->  ~/workspace')
    end
    it '#inspect' do
      expect(p1.inspect).to match(%r(name: '#{p1.name}', path: '#{p1.relative_path}'))
    end
  end


  describe '#filtered_paths' do
    describe 'automatically creates accessors to full_path based on filters' do
      let(:rel_path) { '~/workspace' }
      let(:abs_path) { ENV['HOME'] + '/workspace' }
      let(:p) { Warp::Dir::Point.new('boo', rel_path ) }

      it 'should properly define absolute_path accessor' do
        expect(p.absolute_path).to eql(abs_path)
      end
      it 'should properly define absolute_path accessor' do
        expect(p.relative_path).to eql(rel_path)
      end
      it 'should properly define absolute_path accessor' do
        expect(p.path).to eql(abs_path)
      end
    end

    describe 'when point warps to a folder with a space in the name' do
      let(:long_path) { '/Documents/My Long Ass Name With Space' }
      let(:pl) { Warp::Dir::Point.new('boo', ENV['HOME'] + long_path) }
      context 'should return quoted result when called' do
        it '#absolute_path' do
          expect(pl.absolute_path).to eql(%Q("#{ENV['HOME']}#{long_path}"))
        end
        it '#relative_path' do
          expect(pl.relative_path).to eql(%Q("~#{long_path}"))
        end
        it '#path' do
          expect(pl.path).to eql(pl.absolute_path)
        end
      end
    end

    describe 'serialization' do
      let(:path) { '~/Documents/My Long Ass Name With Space' }
      let(:name) { 'boo' }
      let(:point) { Warp::Dir::Point.new(name, path) }
      let(:serialized_string) { "#{name}:#{Warp::Dir.absolute(path)}" }

      context '#serialize' do
        it 'should correctly serialize warp point' do
          expect(point.serialize).to eql(serialized_string)
        end
      end
      context '#deserialize' do
        let(:restored_point) { Warp::Dir::Point.deserialize(serialized_string) }
        it 'should correctly serialize warp point' do
          expect(point).to eql(restored_point)
        end
      end
    end
  end
end
