require 'warp/dir/command'

require 'colored'
module Warp
  module Dir
    class Command
      class Warp  < Warp::Dir::Command
        class << self
          def description
            %q(Jumps to the pre-defined warp point)
          end
        end
        def run
          raise ::Warp::Dir::Errors::PointNotFound.new(point) unless point
          if store.config.verbose
            STDERR.puts "warping from #{path} to".blue.bold + " #{point.absolute_path}".yellow.bold
          end
          STDOUT.puts "cd #{point.absolute_path}"
          exit 0
        end
      end
    end
  end
end
