require 'spec_helper'

RSpec.describe Warp::Dir::Commands::Add do
  let(:command) { Warp::Dir::Commands::Add }

  describe '#help' do
    it 'should define a help message' do
      expect(command.help).to eql('add             Adds the current directory as a new warp point')
    end
  end

  describe '#run' do
    include_context 'fake_serializer'
    let(:store) { double }
    it 'should call #save! on store after adding new wp' do
      expect(store).to receive(:[]).and_return(nil)
      expect(store).to receive(:add).with(wp_name, wp_path).and_return(point)
      expect(store).to receive(:save!)
      command.new(store, wp_name, wp_path).run
    end
  end

end
