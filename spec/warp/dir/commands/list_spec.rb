require 'spec_helper'
require 'warp/dir/formatter'

RSpec.describe Warp::Dir::Command::List do

  let(:commander) { Warp::Dir.commander }
  let(:list) { Warp::Dir::Command::List }

  describe '#help' do
    it 'should define a help message' do
      expect(list.help).to eql('list            Print all stored warp points')
    end
  end

  describe '#run' do
    include_context :fake_serializer
    include_context :initialized_store

    let(:formatter) { Warp::Dir::Formatter.new(store) }
    let(:output) { formatter.format_store(:ascii) }
    before do
      commander.configure(store)
      store.add(point)
    end

    it 'should return formatted warp points from the store' do
      expect(output).to eql(%Q{harro  ->  ~/workspace/tinker-mania})
    end

    it 'should return response and print the listing' do
      response = list.new.run
      expect(response.messages.first).to eql(output)
      expect(STDOUT).to receive(:printf).with("printf '#{output}\n'").and_return(nil)
      response.print
    end
  end
end
