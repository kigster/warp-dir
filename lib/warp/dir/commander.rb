require 'set'
require 'warp/dir/errors'
require 'warp/dir/formatter'
require 'singleton'
module Warp
  module Dir
    class Commander
      include Singleton

      attr_reader :commands
      attr_accessor :command_map

      def initialize
        @commands ||= Set.new # a pre-caution, normally it would already by defined by now
        @command_map   = {}
      end

      def register(command)
        @commands << command if command
        self
      end

      def installed_commands
        @commands.map(&:command_name)
      end

      def lookup(command_name)
        reindex!
        command_map[command_name]
      end

      def find(command_name)
        command = lookup(command_name)
        if command.nil?
          raise ::Warp::Dir::Errors::InvalidCommand.new(command_name)
        end
        command
      end

      def run(command_name, *args)
        cmd = find command_name
        raise ::Warp::Dir::Errors::InvalidCommand.new(command_name) unless cmd.is_a?(warp::Dir::Command)
        cmd.new(*args).run
      end

      def reindex!
        commands.each do |command|
          if command.respond_to?(:aliases)
            command.aliases.each do |an_alias|
              if self.command_map[an_alias] && !self.command_map[an_alias] == command
                raise Warp::Dir::Errors::InvalidCommand.new("Duplicate alias for command #{command}")
              end
              self.command_map[an_alias] = command
            end
          end
          self.command_map[command.command_name] = command
        end
        self
      end

      def validate!
        self.commands.delete_if do |subclass|
          if !subclass.respond_to?(:abstract_class?) && !subclass.method_defined?(:run)
            raise ::Warp::Dir::Errors::InvalidCommand.new(subclass)
          end
          subclass.respond_to?(:abstract_class?) || !subclass.method_defined?(:run)
        end
      end
    end
  end
end
