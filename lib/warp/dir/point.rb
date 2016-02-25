require 'forwardable'
require 'digest'
module Warp
  module Dir
    class Point
      attr_accessor :full_path, :name

      def initialize(name, full_path)
        raise ArgumentError.new ':name is required' if name.nil?
        raise ArgumentError.new ':full_path is required' if full_path.nil?
        @full_path = Warp::Dir.absolute full_path
        @name      = name.to_sym
      end

      def absolute_path
        full_path
      end

      def relative_path
        Warp::Dir.relative full_path
      end

      def path
        absolute_path
      end

      def inspect
        sprintf("(#{object_id})[name: '%s', path: '%s']", name, relative_path)
      end

      def to_s(width = 0)
        sprintf("%#{width}s  ->  %s", name, relative_path)
      end

      def hash
        Digest::SHA1.base64digest("#{full_path.hash}#{name.hash}").hash
      end

      def eql?(another)
        return false unless another.is_a?(Warp::Dir::Point)
        %i(name full_path).each do |attribute|
          return false unless send(attribute) == another.send(attribute)
        end
        true
      end

    end
  end
end
