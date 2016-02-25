#!/usr/bin/env ruby
require 'bundler/setup'
require 'warp/dir'
require 'warp/dir/command'
require 'slop'
require 'colored'
require 'pp'

module Warp
  module Dir
    USAGE = <<-EOF
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
      def not_a_flag arg
        arg && !arg[0].eql?('-')
      end
      def shift_non_flag_argument
        if not_a_flag ARGV[0]
          return ARGV.shift
        end
        nil
      end

      def run
        @verbose = false
        @command_manager = ::Warp::Dir::Command
        begin
          # Slop v4 no longer supports commands, so we fake it:
          # if the first argument does not start with a dash, it must be a command.
          # So fake-add `--command` flag in front of it.
          first_argument = shift_non_flag_argument
          @command       = first_argument if first_argument && @command_manager.find(first_argument.to_sym)
          second_argument= shift_non_flag_argument
          @point         = second_argument

          opts           = Slop::Options.new
          opts.banner    = USAGE
          @command_manager.installed_commands.map(&:command_name).each do |installed_command|
            opts.banner << sprintf("    %s\n", @command_manager.find(installed_command).help)
          end

          opts.banner << "\n"
          opts.banner << '  Flags:'
          opts.string '-m', '--command',    '<command>      – command to run, ie. add, ls, list, rm, etc.'
          opts.string '-p', '--warp-point', '<point-name>   – name of the warp point'
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

          @result = nil
          begin
            parser  = Slop::Parser.new(opts)
            @result = parser.parse(ARGV)
          rescue Slop::UnknownOption => e
            STDERR.puts "Invalid option: #{e.message}".red
            exit 1
          end

          @config            = Warp::Dir::Config.new(@result.to_hash)
          @verbose           = true if @config.verbose
          @store             = Warp::Dir::Store.singleton(@config)

          if @config.warp
            @config.command  = :warp
            @config.warp_point = @config.warp
          end

          Warp::Dir::Command.init(@store)

          @config.command    ||= @command if @command
          @config.warp_point ||= @point if @point

          if @config.debug
            pp @config
            pp @store
          end

          if @config.command
            command_class = @command_manager.find(@config.command)
            if command_class
              command_class.new(@config.warp_point).run
            else
              STDERR.puts "command '#{@config.command}' was not found.".red
            end
          else
            if @result.help?
              puts @result.to_s.blue.bold
              exit 0
            else
              STDERR.puts "#{$0}: passing #{@argv ? @argv.join(', ') : 'no arguments'} is invalid.".white_on_red
              puts @results.to_s.blue
              abort
            end
          end
        rescue SystemExit
          return
        rescue Exception => e
          printf("ERROR: received exception #{e.class}, #{e.message}".red.bold + "\n".white)
          printf(e.backtrace.join("\n\t").yellow.bold + "\n")
          if @verbose
            require 'pp'
            pp @manager
            pp @config
            pp @storee
          end
        end
      end
    end
  end
end
