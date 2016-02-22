module Warp
  module Dir
    class Point
      attr_accessor :name, :full_path

      def initialize name, full_path
        raise ArgumentError.new ":name is required" if name.nil?
        raise ArgumentError.new ":full_path is required" if full_path.nil?

        @name = name
        @full_path = full_path
      end

      def path
        Warp::Dir.canonical self.full_path
      end

      def inspect
        sprintf("{ name: '%s', path: '%s' }", name, path)
      end

      def to_s width = ""
        sprintf("\t%-#{width}s > %s\n", name, full_path)
      end

      def puts(width = "")
        puts self.to_s(width)
      end

      class << self

        def print(points)
          longest_key = points.keys.max { |a, b| a.length <=> b.length }
          points.each { |point| point.puts(longest_key) }
        end

      end
    end
  end
end
