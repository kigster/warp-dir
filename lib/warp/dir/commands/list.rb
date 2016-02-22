require 'warp/dir/commands'
module Warp
  module Dir
    module Commands
      class List < Base
        class << self
          def description
            %q(Print all stored warp points)
          end
        end
        def run
          Warp::Dir::Point.print(store.points_map)
        end
      end
    end
  end
end
