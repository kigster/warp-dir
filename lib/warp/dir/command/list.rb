require 'warp/dir/command'
require 'warp/dir/formatter'

module Warp
  module Dir
    class Command
      class List < Warp::Dir::Command
        class << self
          def description
            %q(Print all stored warp points)
          end
        end
        def run
          s = self.store
          finish :success do
            message ::Warp::Dir::Formatter.new(s).format_store
          end
        end
      end
    end
  end
end
