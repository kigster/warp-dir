require_relative 'base'
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
          STDOUT.puts store.formatted(:bash)
        end
      end
    end
  end
end
