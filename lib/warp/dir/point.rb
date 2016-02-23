module Warp
  module Dir
    class Point
      ATTRS = %i(full_path name)
      attr_accessor *ATTRS
      class << self
        def print(points)
          longest_key = points.keys.max { |a, b| a.length <=> b.length }
          points.values.each { |point| point.print(longest_key.length) }
        end
      end

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

      def print(width = 0)
        puts self.to_s(width)
      end

      def inspect
        sprintf("{ name: '%s', path: '%s' }", name, path)
      end

      def to_s width = 0
        sprintf("%#{width}s  ->  %s", name, relative_path)
      end

      def hash
        sum = ATTRS.inject("") do |sum, attribute|
          sum += send(attribute).hash.to_s
        end
        Digest::SHA1.base64digest(sum).hash
      end

      def eql?(another)
        return false unless another.is_a?(Warp::Dir::Point)
        ATTRS.each do |attribute|
          return false unless send(attribute).eql?(another.send(attribute))
        end
      end

    end
  end
end
