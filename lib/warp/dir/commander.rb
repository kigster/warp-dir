require 'set'
require 'warp/dir/errors'
require 'warp/dir/formatter'
require 'singleton'
module Warp
  module Dir
    class Commander
      include Singleton

      attr_reader :store, :commands, :formatter
      def initialize
        @commands  ||= Set.new # a pre-caution, normally it would already by defined by now
      end

      def configure(store)
        @store     = store
        @formatter = ::Warp::Dir::Formatter.new(@store)
        validate!
      end

      def register(command)
        @commands << command if command
        self
      end

      def installed_commands
        commands.to_a.map(&:command_name)
      end

      def find(command_name)
        subset = self.commands.classify { |cmd| cmd.command_name }[command_name]
        raise ::Warp::Dir::Errors::InvalidCommand.new(command_name) unless subset && !subset.empty?
        subset.first
      end

      def run(command_name, *args)
        cmd = find command_name
        raise ::Warp::Dir::Errors::InvalidCommand.new(command_name) unless cmd.is_a?(warp::Dir::Command)
        cmd.new(*args).run
      end

      private

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
