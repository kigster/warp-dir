require 'spec_helper'
require 'warp/dir'
RSpec.describe Warp::Dir::Point do
  include_context "fake_serializer"
  let(:path_absolute) { ENV['HOME'] + '/workspace' }
  let(:path_relative) { '~/workspace' }
  let(:p1) { Warp::Dir::Point.new('p', ENV['HOME'] + '/workspace') }

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
    it '#formatted' do
      expect(p1.formatted).to eql("p  ->  ~/workspace")
    end
  end

  describe 'Collection' do
    let(:p2) { Warp::Dir::Point.new('n', ENV['HOME'] + '/workspace/new-project') }
    let(:collection) { Warp::Dir::Point::Collection.new [p1, p2] }
    describe 'delegates methods to the Array class' do
      it '#:[]' do
        expect(collection[1]).to eql(p2)
      end
      it '#size' do
        expect(collection.size).to eql(2)
      end
      it '#<<' do
        collection << Warp::Dir::Point.new('123', '436')
        expect(collection.size).to eql(3)

      end
      it '#map,#each' do
        expect(collection.map(&:formatted)).to eql([
                                                     "p  ->  ~/workspace",
                                                     "n  ->  ~/workspace/new-project"
                                                   ])
        paths = []
        collection.each { |p| paths << p.relative_path }
        expect(paths).to eql(%w(~/workspace ~/workspace/new-project))
      end
      it '#:[]' do
        expect(collection[1]).to eql(p2)
      end
      it '#formatted' do
        expect(collection.formatted).to eql("n  ->  ~/workspace/new-project\np  ->  ~/workspace")
      end
      it '#formatted sorted' do
        expect(collection.formatted(:ascii, :path)).to eql("p  ->  ~/workspace\nn  ->  ~/workspace/new-project")
      end
    end
  end
end
