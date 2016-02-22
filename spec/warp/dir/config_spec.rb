require 'spec_helper'

describe Warp::Dir::Config do
  let(:c1) { Warp::Dir::Config.new(blah: 'blahblah') }

  it 'should have a default folder' do
    expect(c1.config).to eql(ENV['HOME'] + '/.warprc')
  end

  it 'should automatically create accessor' do
    expect(c1.blah).to eql('blahblah')
  end

  it 'should add new parameter to the params array' do
    expect(c1.params).to eql([:config, :blah])
  end

  it 'should be able to create a attr_writer also' do
    c1.blah = 'another blah'
    expect(c1.blah).to eql('another blah')
  end

  describe 'when another instance of the config is created' do
    let(:c2) { Warp::Dir::Config.new(poo: 'boo') }

    it 'should only have one parameter for this class' do
      expect(c1.respond_to?(:poo)).to be_falsey
      expect(c2.respond_to?(:poo)).to be_truthy

      expect(c1.respond_to?(:blah)).to be_truthy
      expect(c2.respond_to?(:blah)).to be_falsey
    end

    it 'should add new parameter to the params array' do
      expect(c2.params).to eql([:config, :poo])
    end

  end
end
