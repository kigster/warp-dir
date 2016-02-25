require 'spec_helper'
require 'warp/dir/store'

RSpec.describe Warp::Dir::Command::Add do
  include_context :fake_serializer

  let(:store) { double }
  let(:command_class) { Warp::Dir::Command::Add }
  let(:commander) { Warp::Dir::Commander.instance }

  let(:wp_path) { ENV['HOME'] + '/workspace/tinker-mania' }
  let(:wp_name) { 'harro' }
  let(:point) { Warp::Dir::Point.new(wp_name, wp_path) }

  let(:add_command) { command_class.new(wp_name, wp_path) }
  before do
    expect(store).to receive(:config).and_return(config).at_least(:once)
    commander.configure(store)
  end

  it 'should have the commander defined' do
    expect(add_command.store).to_not be_nil
  end

  describe '#help' do
    it 'should define a help message' do
      expect(add_command.command_name).to eql(:add)
      expect(add_command.description).to eql(%q(Adds the current directory as a new warp point))
      expect(add_command.help).to eql('add             Adds the current directory as a new warp point')
    end
  end

  describe '#run' do
    it 'should call #save! on store after adding new wp' do
      expect(store).to receive(:add_by_name).with(wp_name, wp_path).and_return(point)
      expect(store).to receive(:save!)
      add_command.run
    end
  end
end
