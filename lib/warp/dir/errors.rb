module Warp
  module Dir
    module Errors
      class Runtime < RuntimeError;
      end

      class StoreFormatError < Warp::Dir::Errors::Runtime
        attr_reader :line

        def initialize(msg, line)
          @line = line
          super msg
        end
      end

      class CommandError < Warp::Dir::Errors::Runtime; end
      class InvalidCommand < Warp::Dir::Errors::CommandError; end

      class PointError < Warp::Dir::Errors::Runtime
        attr_reader :point

        def initialize(msg, point)
          @point = point
          super msg
        end
      end

      class PointUnknown < Warp::Dir::Errors::PointError
        def initialize point
          super "Unknown warp point #{point.inspect}", point
        end
      end

      class PointNotFound < Warp::Dir::Errors::PointError
        def initialize
          super "No warp point found to #{Warp::Dir::pwd}", nil
        end
      end

      class PointIsOrphan < Warp::Dir::Errors::PointError
        def initialize point
          super "Orphaned warp point #{point.inspect} (non-existent directory)", point
        end
      end

      class PointAlreadyExists < Warp::Dir::Errors::PointError
        def initialize point
          super "Warp point #{point.inspect} already exists. Use --force to overwrite", point
        end
      end
    end
  end
end
