require 'warp/dir'
require 'warp/dir/errors'
require 'colored'
require 'thread'
module Warp
  module Dir
    class Formatter
      DEFAULT_FORMAT = :ascii

      attr_accessor :store

      def initialize(store)
        @store  = store
        @config = store.config
      end

      def unhappy(exception: nil, message: nil)
        out = 'Whoops! – '.white
        out << "#{exception.message} ".red if exception && !message
        out << "#{message} ".red if !exception && message
        out << "#{exception.message}:\n#{message}".red if message && exception
        out << "\n"
        print ? STDERR.printf(out) : out
      end

      def self.format_point(point, *args)
        PointFormatter.new(point).format(*args)
      end

      def format_store(*args)
        StoreFormatter.new(store).format(*args)
      end

      def happy(message: nil)
        STDOUT.printf(message.blue.bold)
      end

      class PointFormatter
        attr_accessor :point

        def initialize(point)
          @point = point
        end

        def format(type = DEFAULT_FORMAT, width = 0)
          case type
            when :ascii
              point.to_s(width)
            else
              raise ArgumentError.new("Type #{type} is not recognized.")
          end
        end
      end

      class StoreFormatter
        attr_accessor :points

        def initialize(store_or_points)
          self.points = store_or_points.is_a?(::Array) ? store_or_points : store_or_points.points
        end

        # find the widest warp point name, and indent them all based on that.
        # make it easy to extend to other types, and allow the caller to
        # sort by one of the fields.
        def format(type = DEFAULT_FORMAT, sort_field = :name)
          longest_key_length = points.map(&:name).map(&:length).sort.last
          Warp::Dir.sort_by(points, sort_field).map do |point|
            PointFormatter.new(point).format(type, longest_key_length)
          end.join("\n")
        end
      end
    end
  end
end

