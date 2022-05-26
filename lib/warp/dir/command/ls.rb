require 'warp/dir/command'
module Warp
  module Dir
    class Command
      class LS < ::Warp::Dir::Command
        description %q(List directory contents of a Warp Point)
        needs_a_point? true
        aliases :dir, :ll

        # @param [Object] args
        def run(opts, *flags)
          point         = store.find_point(point_name)
          $stderr.puts "FLAGS: [#{flags}]".bold.green if config.debug

          command_flags = if flags && !flags.empty?
                            flags
                          else
                            ['-al']
                          end
          command = "ls #{command_flags.join(' ')} #{point.path}/"
          $stderr.puts 'Command: '.yellow + command.bold.green if config.debug
          ls_output     = `#{command}`
          $stderr.puts 'Output:  '.yellow + ls_output.bold.blue if config.debug
          on :success do
            message ls_output.bold
          end
        end
      end
    end
  end
end
