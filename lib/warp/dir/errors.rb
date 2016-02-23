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

      class CommandError < Warp::Dir::Errors::Runtime
        attr_reader :command
        def initialize(command)
          @command = command
          super "#{self.class.name}: for command #{command}"
        end
      end
      class InvalidCommand < Warp::Dir::Errors::CommandError; end


      class PointError < Warp::Dir::Errors::Runtime
        attr_reader :point
        def initialize(point)
          @point = point
          super "#{self.class.name}: for point #{point}"
        end
      end
      class PointUnknown < Warp::Dir::Errors::PointError; end
      class PointNotFound < Warp::Dir::Errors::PointError; end
      class PointIsOrphan < Warp::Dir::Errors::PointError; end
      class PointAlreadyExists < Warp::Dir::Errors::PointError; end
    end
  end
end
