require 'warp/dir/command'

require 'colored'
module Warp
  module Dir
    class Command
      class Warp < Warp::Dir::Command
        description %q(Jumps to the pre-defined warp point (command optional))
        needs_a_point? true

        def run(*args)
          warp_to_path = nil
          if point.nil? && point_name
            begin
              self.point = store[point_name]
            rescue ::Warp::Dir::Errors::PointNotFound
            end
          end
          if point
            warp_to_path = point.absolute_path
          else
            files         = ::Dir.glob("#{point_name}*")
            warp_to_path = files.first if files.size == 1
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
