require_relative 'base'
module Warp
  module Dir
    module Commands

      class Manager
        def initialize
          Base.validate!
        end

        def find command
          Base.installed_commands[command.to_sym]
        end

        def commands
          Base.installed_commands.keys
        end

        def run! command, *args
          cmd = find(command)
          raise ::Warp::Dir::Errors::InvalidCommand.new(command) unless cmd.is_a?(Class)
          cmd.new(*args).run
        end

        def inspect
          Base.installed_commands.inspect
        end
      end
    end
  end
end
