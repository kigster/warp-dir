require 'warp/dir/command'

require 'colored'
module Warp
  module Dir
    class Command
      class Warp < Warp::Dir::Command
        description %q(Jumps to the pre-defined warp point (command optional))
        needs_a_point? true

        def run(*args)
          if point.nil? && point_name
            begin
              self.point = store[point_name]
            rescue ::Warp::Dir::Errors::PointNotFound
            end
          end
          warp_to_path = if point
            point.absolute_path
          else
            point_name if ::Dir.exist?(point_name.to_s)
          end
          raise ::Warp::Dir::Errors::PointNotFound.new(point_name) unless warp_to_path
          on :shell do
            message "cd #{warp_to_path}"
          end
        end
      end
    end
  end
end
