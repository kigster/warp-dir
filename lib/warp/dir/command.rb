require 'set'
require 'warp/dir/errors'
require 'warp/dir/formatter'
module Warp
  module Dir
    class Command
      class << self
        attr_accessor :store, :installed_commands, :initialized, :command_lookup

        def init(store)
          raise 'Already initialized' if self.initialized
          @store       = store
          @formatter   = ::Warp::Dir::Formatter.new(@store)
          @initialized = false
          validate!
        end

        def store
          @store
        end

        def inherited(subclass)
          @installed_commands ||= Set.new
          @installed_commands << subclass
        end

        def find(command)
          @command_lookup ||= self.installed_commands.classify { |cmd| cmd.command_name }
          subset = self.command_lookup[command.to_sym]
          raise ::Warp::Dir::Errors::InvalidCommand.new(command) unless subset && !subset.empty?
          subset.first
        end

        def installed_command_names
          self.installed_commands.to_a.map(&:command_name)
        end

        def run(command, *args)
          cmd = find(command)
          raise ::Warp::Dir::Errors::InvalidCommand.new(command) unless cmd.is_a?(Class)
          cmd.new(*args).run
        end

        def command_name
          self.name.gsub(/.*::/, '').downcase.to_sym
        end

        def help
          sprintf('%-16s%s', self.command_name, self.send(:description))
        end



        private

        def validate!
          self.installed_commands.delete_if do |subclass|
            if !subclass.respond_to?(:abstract_class?) && !subclass.method_defined?(:run)
              raise ::Warp::Dir::Errors::InvalidCommand.new(subclass)
            end
            subclass.respond_to?(:abstract_class?) || !subclass.method_defined?(:run)
          end
          @initialized = installed_commands.size > 0 ? true : false
        end

      end

      attr_reader :warp_point, :path, :point, :config, :store

      def initialize(warp_point = nil, path = ::Warp::Dir.pwd)
        @store      = self.class.superclass.store
        @warp_point = warp_point
        @path       = path
        @point      = warp_point ? store[warp_point] : nil
        @config     = @store.config
      end

      def chain_command(another_command)
        command = self.class.find(another_command.name)
        command.new(warp_point, path).run
      end

      def happy(*args)
        STDOUT.printf(*args)
      end

      def unhappy(*args)
        STDERR.printf(*args)
      end

      def inspect
        "#{self.name}[#{self.command}]->(#{self.description})"
      end

      def puts(stream, *args)
        if store.shell
          stream.printf("printf \"#{args.join(', ')}\n\"")
        else
          stream.printf("#{args.join(', ')}\n")
        end
      end
    end
  end
end
Warp::Dir.require_all_from '/dir/commands'
