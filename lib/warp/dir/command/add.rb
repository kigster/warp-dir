require 'warp/dir/command'
module Warp
  module Dir
    class Command
      class Add < Warp::Dir::Command
        class << self
          def description
            %q(Adds the current directory as a new warp point)
          end
        end
        def run
          @store.add_by_name warp_point, path
          @store.save!
        rescue ::Warp::Dir::Errors::PointAlreadyExists => e
          unhappy(e.message)
        end
      end
    end
  end
end
