require 'spec_helper'
require 'warp/dir/store'

RSpec.describe Warp::Dir::Command::Add do
  include_context :fake_serializer

  let(:store) { double }
  let(:command_class) { Warp::Dir::Command::Add }
  let(:commander) { Warp::Dir::Commander.instance }

  let(:wp_path) { "#{::Dir.home}/workspace/tinker-mania" }
  let(:wp_name) { 'harro' }
  let(:point) { Warp::Dir::Point.new(wp_name, wp_path) }

  let(:add_command) { command_class.new(store, wp_name, wp_path) }

  before do
    expect(store).to receive(:config).and_return(config).at_least(:once)
  end

  it 'should have the commander defined' do
    expect(add_command.store).to_not be_nil
  end

  describe '#help' do
    it 'should define a help message' do
      expect(add_command.command_name).to eql(:add)
      expect(add_command.description).to match(%r(Adds the current directory)i)
      expect(add_command.help).to match /add/
      expect(add_command.help).to match /Adds the current directory/
    end
  end

  describe '#run' do
    it 'should call #save! on store after adding new wp' do
      expect(store).to receive(:insert).with(point_name: wp_name, point_path: wp_path, overwrite: false).and_return(point)
      add_command.run
    end
  end

end
