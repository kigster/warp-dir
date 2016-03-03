module Warp
  module Dir
    class Response
      #
      # Three cases:
      #
      # Use Case                       exit code       stream
      #----------------------------------------------------------------
      # Information / Help / List              0       STDOUT
      # Error occured                          1       STDERR
      # Execute Shell Command                  2       STDOUT

      ResponseType = Struct.new(:exit_code, :stream) do
        def print(msg)
          stream.printf(msg)
        end
      end

      INFO  = ResponseType.new(0, STDOUT)
      ERROR = ResponseType.new(1, STDERR)
      SHELL = ResponseType.new(2, STDOUT)

      SHELL.instance_eval do
        def print(msg)
          stream.printf(msg + "\n")
        end
        def exit_code=(value)
        end
      end

      RETURNS = {
        success: INFO,
        error:   ERROR,
        shell:   SHELL
      }

      class << self
        def response_type(type)
          resp = Warp::Dir::Response::RETURNS[type]
          raise ::ArgumentError.new("Can't find response object for type #{type}") unless resp
          resp
        end
      end

      attr_writer :type
      attr_accessor :messages, :kernel

      def initialize(a_type = nil)
        @messages = []
        @type     = a_type

        if a_type && a_type.is_a?(Symbol)
          @type = self.class.response_type(a_type)
        end
      end

      def configure(&block)
        self.instance_eval(&block)
      end

      def message(message = nil)
        @messages << message if message
        @messages.join('')
      end

      def type(a_type = nil)
        @type = a_type if a_type
        @type
      end

      def code(value = nil)
        @type.exit_code = value if value
        @type.exit_code
      end

      def print(&block)
        configure(&block) if block
        raise ::ArgumentError.new('No type defined for Response object') unless @type
        @type.print(@messages.shift) until @messages.empty?
      end

      def exit(&block)
        print(&block)
        raise ::ArgumentError.new('No type defined for Response object') unless @type
        system_exit(@type.exit_code)
      end

      private

      def system_exit(code)
        Kernel.exit(code) unless self.class.exit_disabled?
      end

      class << self
        attr_accessor :exit_disabled

        def enable_exit!
          self.exit_disabled = false
        end

        def disable_exit!
          self.exit_disabled = true
        end

        def exit_disabled?
          self.exit_disabled
        end
      end

    end
  end
end
