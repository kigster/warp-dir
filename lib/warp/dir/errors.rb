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

      class StoreUninitialized < Warp::Dir::Errors::Runtime; end
      class StoreAlreadyInitialized < Warp::Dir::Errors::Runtime; end

      # This is a generic Exception that wraps an object passed to the
      # initializer and assumed to be the reason for the failure.
      # Message is optional, but each concrete exception should provide
      # it's own concrete message
      class InstanceError < Warp::Dir::Errors::Runtime
        attr_accessor :instance
        def initialize(message = nil)
          super message ? message : "#{self.class.name}->[#{instance}]"
        end

        def name
          super.gsub(%r{#{self.class.name}}, '')
        end
      end

      class InvalidCommand < ::Warp::Dir::Errors::InstanceError
        def initialize(instance = nil)
          self.instance = instance
          super instance.is_a?(Symbol) ? "command #{instance} is invalid" : instance
        end
      end

      class PointNotFound < ::Warp::Dir::Errors::InstanceError
        def initialize(point)
          self.instance = point
          super "point '#{point}' is not found"
        end
      end
      class PointAlreadyExists < ::Warp::Dir::Errors::InstanceError
        def initialize(point)
          self.instance = point
          super "point '#{point.name}' already exists. Pass --force to overwrite."
        end
      end
    end
  end
end
