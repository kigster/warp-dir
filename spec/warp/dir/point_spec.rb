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
      expect(p1.inspect).to match(%r{name: '#{p1.name}', path: '#{p1.relative_path}'})
    end
  end

end
