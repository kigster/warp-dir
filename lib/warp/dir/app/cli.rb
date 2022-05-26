#!/usr/bin/env ruby
require 'warp/dir'
require 'slop'
require 'colored'

module Warp
  module Dir
    module App
      class CLI
        attr_accessor :argv, :config, :commander, :store, :validated, :opts, :flags

        def initialize(argv)
          self.argv      = argv

          # flags are everything that follows -- and is typically flags for the command.
          # for example: 'wd ls project-point -- -alF' would extract flags = [ '-alF' ]
          self.flags     = extract_suffix_flags(argv.dup)
          self.flags.flatten!
          self.commander = ::Warp::Dir::Commander.instance
          self.config    = ::Warp::Dir::Config.new
          self.opts      = nil
        end

        def validate
          self.validated = false
          no_arguments   = argv.empty?
          commands       = shift_non_flag_commands
          self.opts      = parse_with_slop(self.argv)
          # merge first few non-flag args which we filtered into `commands` hash
          # merge onto the hash resulting from options
          # and pass on to override the default config opts for the final config.
          config.configure(opts.to_hash.merge(commands))

          self.store     = Warp::Dir::Store.new(config, Warp::Dir::Serializer::Dotfile)

          config.command = :help if (opts.help? || no_arguments)
          config.command = :warp if config.warp || config.command == 'warp'

          String.disable_colors if config.no_color

          if config[:command]
            self.validated = true
          else
            raise Warp::Dir::Errors::InvalidCommand.new('Unable to determine what command to run.'.red)
          end
          yield self if block_given?
          validated
        end

        def run(&block)
          validate unless validated?
          response = process_command
          yield response if block_given?
          response
        rescue Exception => e
          if config.debug
            $stderr.puts(e.inspect)
            $stderr.puts(e.backtrace.join("\n"))
          end
          on :error do
            message e.message.red
          end
        end

        private

        def on(*args, &block)
          response = Warp::Dir.on(*args, &block)
          response.config = self.config
          response
        end

        def process_command
          argv = self.argv
          if config.command
            command_class = commander.find(config.command)
            if command_class
              command_class.new(store, config.point).run(opts, *flags)
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
          opts.banner = nil
          opts.string  '-m', '--command', '<command>      – command to run, ie. add, ls, list, rm, etc.'
          opts.string  '-p', '--point',   '<point-name>   – name of the warp point'
          opts.string  '-w', '--warp',    '<warp-point>   – warp to a given point'
          opts.bool          '--no-color','               - do not use ASCII color'
          opts.bool    '-f', '--force',   '               - force, ie. overwrite existing point when adding'
          opts.bool    '-h', '--help',    '               – show help'
          opts.bool    '-v', '--verbose', '               – enable verbose mode'
          opts.bool    '-q', '--quiet',   '               – suppress output (quiet mode)'
          opts.bool    '-d', '--debug',   '               – show stacktrace if errors are detected'
          opts.string  '-s', '--dotfile', '<dotfile>      – shell init file to append the wd wrapper, eg. ~/.bashrc'
          opts.string  '-c', '--config',  "<config>       – location of the configuration file (default: #{Warp::Dir.default_config})", default: Warp::Dir.default_config
          opts.on      '-V', '--version', '               – print the version' do
            puts "Version #{Warp::Dir::VERSION}"
            exit
          end

          Slop::Parser.new(opts).parse(arguments)
        end

        # Given args of the form:
        # [ 'ls' 'project' --verbose --debug -- -alF ]
        # this returns:
        # {
        #    command: :ls,
        #      point: :project
        # }
        def shift_non_flag_commands
          result = {}
          non_flags = []
          non_flags << argv.shift while not_a_flag(argv.first)
          case non_flags.size
            when 1
              argument = non_flags.first.to_sym
              if commander.lookup(argument)
                result[:command] = argument
              else
                result[:command] = :warp
                result[:point] = argument
              end
            when 2
              result[:command], result[:point] = non_flags.map(&:to_sym)
            when 3
              #
              # This is for the hypothetical but awesome future:
              #
              #   wd add proj_remote kig@remote.server.com:~/workspace/proj
              #   wd proj_remote
              #
              # >>>>.... ssh kig@remote.server.com -c "cd ~/workspace/proj"
              #
              result[:command], result[:point], result[:point_path] = non_flags.map(&:to_sym)
          end
          result
        end

        def extract_suffix_flags(list)
          element = list.shift until element.eql?('--') || list.empty?
          list
        end

        def validated?
          self.validated
        end

        def not_a_flag(arg)
          arg && !arg[0].eql?('-')
        end
      end
    end
  end
end
