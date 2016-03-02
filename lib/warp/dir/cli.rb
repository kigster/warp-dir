#!/usr/bin/env ruby
require 'bundler/setup'
require 'warp/dir'
require 'slop'
require 'colored'
require 'pp'

module Warp
  module Dir
    USAGE = <<EOF
  Usage:  wd [ --command ] [ show | list | clean | validate | wipe ]          [ flags ]
          wd [ --command ] [ add  [ -f/--force ] | rm | ls | path ] <point>   [ flags ]
          wd --help | help

  Warp Point Commands:
    add   <point>   Adds the current directory as a new warp point
    rm    <point>   Removes a warp point
    show  <point>   Show the path to the warp point
    ls    <point>   Show files from tne warp point
    path  <point>   Show the path to given warp point

  Global Commands:
    show            Print warp points to current directory
    clean           Remove points warping to nonexistent directories
    help            Show this extremely unhelpful text
EOF
    class CLI
      attr_accessor :argv, :config, :commander, :store, :response

      def initialize(argv)
        self.argv      = argv
        self.commander = ::Warp::Dir.commander
        self.config    = ::Warp::Dir.config
        self.response  = ::Warp::Dir::Response.new
      end

      def run
        config.verbose = false
        config.debug = false
        extract_non_flags!

        result = parse_with_slop!
        config.configure(result.to_hash)

        if config.debug
          require 'pp'
          printf('_' * 80).green + "\n"
          pp config, argv, commander
          printf('_' * 80).green + "\n"
        end

        begin
          store          = Warp::Dir.store(config, Warp::Dir::Serializer::Dotfile)
          config.command = :warp if !config.command && config.warp
          Warp::Dir.commander.configure(store)

          pp store
          if config.command
            command_class = commander.find(config.command)
            if command_class
              response.type = command_class.new(config.point).run
            else
              STDERR.puts "command '#{config.command}' was not found.".red
            end
          else
            if result.help?
              response
            else
              response = Response.error
              response.messages << "#{$0}: passing #{argv ? argv.join(', ') : 'no arguments'} is invalid.".red
            end
            response << result.to_s.blue
          end
        rescue SystemExit
          return
        rescue Exception => e
          printf("ERROR: received exception #{e.class}, #{e.message}".red.bold + "\n".white)
          printf(e.backtrace.join("\n\t").yellow.bold + "\n")
        end

        response
      end

      #______________________________________________________________________________________________________

      private

      def parse_with_slop!
        opts        = Slop::Options.new
        opts.banner = USAGE
        commander.commands.map(&:command_name).each do |installed_commands|
          opts.banner << sprintf("    %s\n", commander.find(installed_commands).help)
        end

        opts.banner << "\n"
        opts.banner << '  Flags:'
        opts.string '-m', '--command',    '<command>      – command to run, ie. add, ls, list, rm, etc.'
        opts.string '-p', '--point',      '<point-name>   – name of the warp point'
        opts.string '-w', '--warp',       '<warp-point>   – warp to a given point'
        opts.bool   '-h', '--help',       '               – show help'
        opts.bool   '-v', '--verbose',    '               – enable verbose mode'
        opts.bool   '-q', '--quiet',      '               – suppress output (quiet mode)'
        opts.bool   '-d', '--debug',      '               – show stacktrace if errors are detected'
        opts.string '-c', '--config',     '<config>       – location of the configuration file (default: ' + Warp::Dir.default_config + ')', default: Warp::Dir.default_config
        opts.boolean'-s', '--shell',      '               – if passed, output is returned for BASH\' eval: eval "($(warp_dir ...))"'
        opts.on     '-V', '--version',    '               – print the version' do
          puts 'Version ' + Warp::Dir::VERSION
          exit
        end

        result = nil
        begin
          parser  = Slop::Parser.new(opts)
          result = parser.parse(argv)
        rescue Slop::UnknownOption => e
          STDERR.puts "Invalid option: #{e.message}".red
          exit 1
        end

        result
      end

      def extract_non_flags!
        non_flags = []
        while is_noflag(argv[0]) do
          non_flags << argv.shift
        end
        case non_flags.size
          when 1
            config.point = non_flags[0]
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
