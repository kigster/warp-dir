require 'spec_helper'
require 'warp/dir/formatter'

RSpec.describe Warp::Dir::Formatter do
  include_context :initialized_store

  let(:path_absolute) { "#{::Dir.home}/workspace" }
  let(:path_relative) { '~/workspace' }
  let(:p1) { Warp::Dir::Point.new('p', "#{::Dir.home}/workspace") }
  let(:p2) { Warp::Dir::Point.new('n', "#{::Dir.home}/workspace/new-project") }

  describe 'with empty store' do
    before do
      store.add(p1)
      store.add(p2)
    end


    # it '#map,#each' do
    #   expect(collection.map(&:formatted)).to eql([
    #                                                'p  ->  ~/workspace',
    #                                                'n  ->  ~/workspace/new-project'
    #                                              ])
    #   paths = []
    #   collection.each { |p| paths << p.relative_path }
    #   expect(paths).to eql(%w(~/workspace ~/workspace/new-project))
    # end
    # it '#:[]' do
    #   expect(collection[1]).to eql(p2)
    # end
    # it '#formatted' do
    #   expect(collection.formatted).to eql("n  ->  ~/workspace/new-project\np  ->  ~/workspace")
    # end
    # it '#formatted sorted' do
    #   expect(collection.formatted(:ascii, :path)).to eql("p  ->  ~/workspace\nn  ->  ~/workspace/new-project")
    # end
  end
end
