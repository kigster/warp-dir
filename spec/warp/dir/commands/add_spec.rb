require 'spec_helper'
require 'warp/dir/store'

RSpec.describe Warp::Dir::Command::Add do

  let(:store) { double }
  let(:command) { Warp::Dir::Command::Add }

  before do
    expect(store).to receive(:config).at_least(:once)
    Warp::Dir::Command.initialized = false
    Warp::Dir::Command.init(store)
  end

  describe '#help' do
    it 'should define a help message' do
      expect(command.command_name).to eql(:add)
      expect(command.description).to eql(%q(Adds the current directory as a new warp point))
      expect(command.help).to eql('add             Adds the current directory as a new warp point')
    end
  end

  describe '#run' do
    let(:wp_path) { ENV['HOME'] + '/workspace/tinker-mania' }
    let(:wp_name) { 'harro' }
    let(:point) { Warp::Dir::Point.new(wp_name, wp_path) }

    it 'should call #save! on store after adding new wp' do
      expect(store).to_not be_nil
      expect(command.superclass.store).to_not be_nil
      expect(store).to receive(:[]).and_return(nil)
      expect(store).to receive(:add_by_name).with(wp_name, wp_path).and_return(point)
      expect(store).to receive(:save!)
      command.new(wp_name, wp_path).run
    end
  end
end
