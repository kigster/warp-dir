#!/usr/bin/env ruby
require 'bundler/setup'
require 'warp/dir'
require 'warp/dir/app/response'
require 'slop'
require 'colored'
require 'pp'

module Warp
  module Dir
    module App
      class CLI
        attr_accessor :argv, :config, :commander, :store

        def initialize(argv)
          self.argv      = argv
          self.commander = ::Warp::Dir.commander
          self.config    = ::Warp::Dir.config
        end

        def run(&block)
          config.verbose = false
          config.debug   = false
          extract_non_flags!

          begin
            result = parse_with_slop(argv)
          rescue Slop::UnknownOption => e
            return on :error do
              "Invalid option: #{e.message}".red
            end
          end

          config.configure(result.to_hash)

          store = Warp::Dir.store(config, Warp::Dir::Serializer::Dotfile)
          Warp::Dir.commander.configure(store)

          config.command = :help if result.help?
          config.command = :warp if !config.command && config.warp

          response = process_command(config)
          yield response if block_given?
          response
        end

        private

        def process_command(config)
          if config.command
            command_class = commander.find(config.command)
            if command_class
              command_class.new(config.point).run
            else
              on :error do
                message "command '#{config.command}' was not found.".red
              end
            end
          else
            on :error do
              message "#{$0}: passing #{argv ? argv.join(', ') : 'no arguments'} is invalid.".red
            end
          end
        end

        def parse_with_slop(arguments)
          opts        = Slop::Options.new
          opts.banner << "\n"
          opts.banner << '  Flags:'
          opts.string  '-m', '--command', '<command>      – command to run, ie. add, ls, list, rm, etc.'
          opts.string  '-p', '--point',   '<point-name>   – name of the warp point'
          opts.string  '-w', '--warp',    '<warp-point>   – warp to a given point'
          opts.bool    '-h', '--help',    '               – show help'
          opts.bool    '-v', '--verbose', '               – enable verbose mode'
          opts.bool    '-q', '--quiet',   '               – suppress output (quiet mode)'
          opts.bool    '-d', '--debug',   '               – show stacktrace if errors are detected'
          opts.string  '-c', '--config',  '<config>       – location of the configuration file (default: ' + Warp::Dir.default_config + ')', default: Warp::Dir.default_config
          opts.boolean '-s', '--shell',   '               – if passed, output is returned for BASH\' eval: eval "($(warp_dir ...))"'
          opts.on      '-V', '--version', '               – print the version' do
            puts 'Version ' + Warp::Dir::VERSION
            exit
          end

          Slop::Parser.new(opts).parse(arguments)
        end

        def extract_non_flags!
          non_flags = []
          while is_noflag(argv[0]) do
            non_flags << argv.shift
          end
          case non_flags.size
            when 1
              config.point   = non_flags[0]
              config.command = :warp
            when 2
              config.command, config.point = non_flags
          end
        end

        def is_noflag arg
          arg && !arg[0].eql?('-')
        end

      end
    end
  end
end
