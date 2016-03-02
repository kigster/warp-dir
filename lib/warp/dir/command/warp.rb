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
          finish :shell do
            message "cd #{point.absolute_path}"
          end
        end
      end
    end
  end
end
