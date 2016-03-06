require 'warp/dir/command'

require 'colored'
module Warp
  module Dir
    class Command
      class Warp < Warp::Dir::Command
        description %q(Jumps to the pre-defined warp point)
        def run
          if point.nil? && point_name
            self.point = store[point_name]
          end
          raise ::Warp::Dir::Errors::PointNotFound.new(point) unless point
          p = point
          on :shell do
            message "cd #{p.absolute_path}"
          end
        end
      end
    end
  end
end
