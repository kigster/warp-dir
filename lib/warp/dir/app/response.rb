require 'singleton'

module Warp
  module Dir
    module App
      class Response
        include Singleton

        # Use Case                       exit code       stream
        #----------------------------------------------------------------
        # Information / Help / List              0       STDOUT
        # Error occured                          1       STDERR
        # Execute Shell Command                  2       STDOUT

        class Type < Struct.new(:exit_code, :stream)
          def print(msg)
            if msg == ' '
              stream.printf(%Q{printf '\\n'; })
            else
              msg.split("\n").each do |line|
                stream.printf(%Q{printf -- '#{line}\\n';})
              end
            end
          end
          def header
            # stream.printf(%q[function wd_out() { ])
          end
          def footer
            # stream.printf(%q[}; wd_out ])
          end
          def to_s
            "code:#{exit_code}, stream:#{stream == STDOUT ? "STDOUT" : "STDERR"}"
          end
        end

        INFO  = Type.new(0, STDOUT)
        ERROR = Type.new(1, STDERR)
        SHELL = Type.new(2, STDOUT)

        SHELL.instance_eval do
          def print(msg)
            stream.printf("#{msg};")
          end

          # can't change exit code in SHELL
          def exit_code=(value)
          end
        end

        RETURN_TYPE = {
          success: INFO,
          error:   ERROR,
          shell:   SHELL
        }

        attr_accessor :messages, :config

        def initialize
          @messages = []
        end

        # Public Methods
        def print
          raise ::ArgumentError.new('No type defined for Response object') unless @type
          @type.header
          @type.print(@messages.shift) until @messages.empty?
          @type.footer
          self
        end

        def exit!
          raise ::ArgumentError.new('No type defined for Response object') unless @type
          system_exit!(@type.exit_code)
        end

        # Configure & Accessors
        def configure(&block)
          self.instance_eval(&block)
          self
        end

        def self.configure(&block)
          self.instance.configure(&block)
        end

        def message(message = nil)
          if message
            @messages << message
            self
          else
            @messages.join('')
          end
        end

        def type(a_type = nil)
          if a_type
            @type = a_type.kind_of?(Warp::Dir::App::Response::Type) ? a_type : RETURN_TYPE[a_type]
            raise(::ArgumentError.new("Can't find response type #{a_type} #{@type}")) unless @type
            self
          else
            @type
          end
        end

        def code(value = nil)
          if value
            @type.exit_code = value
            self
          else
            @type.exit_code
          end
        end

        def inspect
          "#{self.class.name}={#{type.inspect}, #{messages.inspect}}"
        end

        def to_s
          "AppResponse[type: {#{type}}, messages: '#{messages.join(' ')}']"
        end

        private

        def system_exit!(code)
          Kernel.exit(code) unless self.class.instance_variable_defined?(:@exit_disabled) && self.class.exit_disabled?
          self
        end

      end
    end
  end
end
