require 'spec_helper'
require 'warp/dir/formatter'
describe Warp::Dir::Command::List do
  let(:command) { Warp::Dir::Command }
  let(:command_list) { Warp::Dir::Command::List }
  describe '#help' do
    it 'define a help message' do
      expect(command_list.help).to eql('list            Print all stored warp points')
    end
  end

  describe '#run' do
    include_context :fake_serializer
    let(:f) { Warp::Dir::Formatter.new(store)}

    before do
      command.initialized = false
      command.init(store)
      store.add(point)
    end

    it 'should properly return formatted warp points from the store' do
      # expect(f.format_store(:bash)).to eql(%Q{printf "harro  ->  ~/workspace/tinker-mania\\n"})
      expect(f.format_store(:ascii)).to eql(%Q{harro  ->  ~/workspace/tinker-mania})
    end

    it 'should call #save! on store after adding new wp' do
      output = f.format_store(:ascii)
      expect(output).not_to eql('')
      expect(output).not_to be_nil
      expect(STDOUT).to receive(:printf).with(output).and_return(nil)
      expect(store).to be_kind_of(Warp::Dir::Store)
      command_list.new().run
    end
  end
end
