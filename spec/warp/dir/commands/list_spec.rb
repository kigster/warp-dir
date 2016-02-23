require 'spec_helper'

describe Warp::Dir::Commands::List do
  let(:command) { Warp::Dir::Commands::List }

  describe '#help' do
    it 'define a help message' do
      expect(command.help).to eql('list            Print all stored warp points')
    end
  end

  describe '#run' do
    include_context 'fake_serializer'
    let(:fake_store) { double }
    before do
      store.add(point)
    end
    it 'should properly return formatted warp points from the store' do
      expect(store.formatted(:bash)).to eql(%Q{printf "harro  ->  ~/workspace/tinker-mania\\n"})
      expect(store.formatted(:ascii)).to eql(%Q{harro  ->  ~/workspace/tinker-mania})
    end
    it 'should call #save! on store after adding new wp' do
      bash_output = store.formatted(:bash)
      expect(bash_output).to_not be_blank

      expect(fake_store).not_to receive(:[])
      expect(fake_store).to receive(:formatted).and_return(bash_output)
      expect(STDOUT).to receive(:puts).with(bash_output).and_return(nil)

      command.new(fake_store).run
    end
  end
end
