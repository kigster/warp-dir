require 'spec_helper'
require 'warp/dir/formatter'

RSpec.describe Warp::Dir::Command::List do

  let(:commander) { Warp::Dir.commander }
  let(:list) { Warp::Dir::Command::List }

  describe '#help' do
    it 'should define a help message' do
      expect(list.help).to match /list/
      expect(list.help).to match /Print all stored warp points/
    end
  end

  describe '#run' do
    include_context :fake_serializer
    include_context :initialized_store

    let(:formatter) { Warp::Dir::Formatter.new(store) }
    let(:output) { formatter.format_store(:ascii) }
    before do
      store.add(point: point)
    end

    it 'should return formatted warp points from the store' do
      expect(output).to eql(%Q{harro  ->  ~/workspace/tinker-mania})
    end

    it 'should return response and print the listing' do
      response = list.new(store).run
      expect(response.messages.first).to eql(output.blue.bold)
      expect($stdout).to receive(:printf).at_least(1).times
      response.print
    end
  end
end
