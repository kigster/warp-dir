require 'warp/dir/commands'
module Warp
  module Dir
    module Commands
      class List < Base
        def run
          Warp::Dir::Point.print(store.points_map)
        end
      end
    end
  end
end
