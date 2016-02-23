require_relative 'base'
module Warp
  module Dir
    module Commands
      class Add < Base
        class << self
          def description
            %q(Adds the current directory as a new warp point)
          end
        end
        def run
          store.add warp_point, path
        end
      end
    end
  end
end
