require 'spec_helper'

RSpec.describe Warp::Dir::Command do
  include_context :initialized_store
  installed_commands = Warp::Dir::Command.installed_commands.dup.freeze

  let(:command) { Warp::Dir::Command }
  let(:commander) { Warp::Dir::Commander.instance }

  describe 'when we remove inherited hierarchy' do
    before do
      commander.commands.clear
    end
    after do
      commander.commands.merge(installed_commands.dup)
    end

    it 'should start with a blank list' do
      expect(commander.commands).to be_empty
    end

    it 'should add a subclass command to the list of installed Command' do
      class Warp::Dir::Command::MyCommand < Warp::Dir::Command; def run; end; end
      expect(commander.installed_commands).to eql([:mycommand])
      expect(commander.find :mycommand).to eql(Warp::Dir::Command::MyCommand)
    end
    describe '#validate!' do
      it 'should raise exception when subclass command does not have a #run method ' do
        class Warp::Dir::Command::Random < Warp::Dir::Command;
        end
        expect(commander.commands).to include(Warp::Dir::Command::Random)
        expect { commander.send(:validate!) }.to raise_error(Warp::Dir::Errors::InvalidCommand)
      end

      it 'should not quietly remove any abstract classes ' do
        class Warp::Dir::Command::Random < Warp::Dir::Command
          def abstract_class?;
            true;
          end
        end
        expect(commander.commands).to eql(Set.new)
      end
    end
  end
end
