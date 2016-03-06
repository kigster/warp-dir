require 'set'
require 'warp/dir/errors'
require 'warp/dir/formatter'
require 'warp/dir/commander'
require 'warp/dir/point'
require 'forwardable'
require_relative 'app/response'

module Warp
  module Dir
    class Command
      class << self
        def command_name
          self.name.gsub(/.*::/, '').downcase.to_sym
        end

        def help
          sprintf('%-25s%s', self.command_name.to_s.yellow, self.send(:description).blue)
        end

        def inherited(subclass)
          ::Warp::Dir::Commander.instance.register(subclass)
          subclass.class_eval do
            extend Forwardable
            def_delegators :@klazz, :command_name, :help, :description
          end

          subclass.instance_eval do
            class << self
              def description value = nil
                @description = value if value
                @description
              end
            end
          end
        end

        def installed_commands
          ::Warp::Dir::Commander.instance.commands
        end
      end

      attr_accessor :store, :formatter, :point_name, :point_path, :point

      def initialize(store, point_name = nil, point_path = nil)
        @store = store
        @formatter = ::Warp::Dir::Formatter.new(@store)
        @klazz = self.class
        if point_name
          if point_name.is_a?(::Warp::Dir::Point)
            self.point = point_name
          else
            self.point_name = point_name
          end
          self.point_path = point_path if point_path
        end
      end

      def config
        self.store.config
      end

      # def chain(another_command)
      #   command = Warp::Dir.commander.find(another_command.name)
      #   command.new(point_name, point_path).run
      # end
      def on(type, &block)
        ::Warp::Dir.on(type, &block)
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
