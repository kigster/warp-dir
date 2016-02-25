require 'spec_helper'

describe Warp::Dir::Config do
  let(:c1) { Warp::Dir::Config.new(blah: 'blah blah') }

  it 'should have a default folder' do
    expect(c1.warprc).to eql(ENV['HOME'] + '/.warprc')
  end

  it 'should automatically create accessors' do
    expect(c1.blah).to eql('blah blah')
  end

  it 'should add new parameter to the params array' do
    expect(c1.variables).to eql([:warprc, :shell, :blah])
  end

  it 'should be able to create a attr_writer also' do
    c1.blah = 'another blah'
    expect(c1.blah).to eql('another blah')
  end

  it 'should be possible to add a new value after instance was created' do
    c1.new_field = 'really new here'
    expect(c1.new_field?).to be_truthy
    expect(c1.new_field).to eql('really new here')
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
      expect(c2.variables).to eql([:warprc, :shell, :poo])
    end

  end
end
