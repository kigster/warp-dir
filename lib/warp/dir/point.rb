module Warp
  module Dir
    class Point
      attr_accessor :name, :full_path

      def initialize name, full_path
        raise ArgumentError.new ":name is required" if name.nil?
        raise ArgumentError.new ":full_path is required" if full_path.nil?
        @full_path  = Warp::Dir.absolute full_path
        @name       = name
      end

      def absolute_path
        full_path
      end

      def relative_path
        Warp::Dir.relative self.absolute_path
      end

      alias_method :path, :relative_path

      def inspect
        sprintf("{ name: '%s', path: '%s' }", name, path)
      end

      def to_s width = 0
        sprintf("%#{width}s  ->  %s\n", name, relative_path)
      end

      def print(width = 0)
        puts self.to_s(width)
      end

      class << self

        def print(points)
          longest_key = points.keys.max { |a, b| a.length <=> b.length }
          points.values.each { |point| point.print(longest_key.length) }
        end

      end
    end
  end
end
