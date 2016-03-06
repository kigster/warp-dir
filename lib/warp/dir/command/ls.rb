require 'warp/dir/command'
module Warp
  module Dir
    class Command
      class LS < Warp::Dir::Command
        description %q(List directory contents of a Warp Point)
        needs_a_point? true
        aliases :dir

        # @param [Object] args
        def run(args)
          point     = store.find_point(point_name)
          flags     = if args && !args.empty?
                        args
                      else
                        [ '-al' ]
                      end
          ls_output = `ls #{flags.join(' ')} #{point.path}/`
          on :success do
            message ls_output.bold
          end
        end
      end
    end
  end
end
