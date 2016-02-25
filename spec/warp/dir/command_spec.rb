require 'spec_helper'

describe Warp::Dir::Command do
  include_context :fake_serializer
  INSTALLED_COMMANDS = Warp::Dir::Command.installed_commands.dup.freeze

  let(:command) { Warp::Dir::Command }
  before do
    command.initialized = false
    command.init(store)
  end

  describe 'when we remove inherited hierarchy' do
    before do
      command.installed_commands = Set.new
    end
    after do
      command.installed_commands = INSTALLED_COMMANDS.dup
    end

    it 'should start with a blank list' do
      expect(command.installed_commands).to be_empty
    end

    it 'should add a subclass command to the list of installed Command' do
      class Warp::Dir::Command::MyCommand < Warp::Dir::Command; def run; end; end
      expect(command.installed_command_names).to eql([:mycommand])
      expect(command.find :mycommand).to eql(Warp::Dir::Command::MyCommand)
    end
    describe '#validate!' do
      it 'should raise exception when subclass command does not have a #run method ' do
        class Warp::Dir::Command::Random < Warp::Dir::Command;
        end
        expect(command.installed_commands).to include(Warp::Dir::Command::Random)
        expect { command.send(:validate!) }.to raise_error(Warp::Dir::Errors::InvalidCommand)
      end

      it 'should not quietly remove any abstract classes ' do
        class Warp::Dir::Command::Random < Warp::Dir::Command
          def abstract_class?;
            true;
          end
        end
        expect(command.installed_commands).to eql(Set.new)
      end
    end
  end
end
