require 'set'
require 'warp/dir/errors'
require 'warp/dir/formatter'
require 'warp/dir/commander'
require 'warp/dir/point'
require 'forwardable'
require_relative 'response'

module Warp
  module Dir
    class Command
      class << self
        def command_name
          self.name.gsub(/.*::/, '').downcase.to_sym
        end

        def help
          sprintf('%-16s%s', self.command_name, self.send(:description))
        end

        def inherited(subclass)
          ::Warp::Dir.commander.register(subclass)
          subclass.class_eval do
            def store
              ::Warp::Dir::Commander.instance.store
            end

            extend Forwardable
            def_delegators :@klazz, :command_name, :help, :description
          end
        end

        def installed_commands
          ::Warp::Dir::Commander.instance.commands
        end
      end

      attr_accessor :point_name, :point_path, :point

      def initialize(point_name = nil, point_path = nil)
        @klazz = self.class
        if point_name
          if point_name.is_a?(::Warp::Dir::Point)
            self.point = point_name
          else
            self.point_name = point_name
          end
          if point_path
            self.point_path = point_path
            unless point
              point = ::Warp::Dir::Point.new(point_name, point_path)
            end
          end
        end
      end

      def config
        self.store.config
      end

      # def chain(another_command)
      #   command = Warp::Dir.commander.find(another_command.name)
      #   command.new(point_name, point_path).run
      # end

      # @param [Object] type – a symbol: :success, :error, :shell
      # @param [Object] block - a block where response is defined
      # eg.
      #
      # finish :success do
      #   code 100
      #   message 'Awesome thanks!'
      # end
      #
      def finish(type, &block)
        Response.new(type).exit(&block)
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
