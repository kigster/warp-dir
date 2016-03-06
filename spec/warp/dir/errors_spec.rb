require 'warp/dir'
require 'spec_helper'

RSpec.describe Warp::Dir::Errors do
  include_context :fake_serializer
  include_context :initialized_store

  it 'should properly throw point already exists error' do
    expect(store.class).to eql(Warp::Dir::Store)
    expect(point.class).to eql(Warp::Dir::Point)

    store.add(point: point.dup)
    point.full_path = '~/booomania'
    expect { store.add(point: point) }.to raise_error(Warp::Dir::Errors::PointAlreadyExists)
  end
end
