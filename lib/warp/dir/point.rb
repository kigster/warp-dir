require 'forwardable'
require 'digest'
module Warp
  module Dir
    # This class encapsulates the tuple: name + path.
    # It provides convenience accessors to retrieve absolute or
    # realtive path of a point, optionally via a set of predefined
    # filters.
    #
    # In addition, this class is responsible for serializing and
    # deserializing itself properly.
    class Point

      # This method creates/defines methods used to
      # access the #full_path component of the Point instance, but
      # enclosing it in a chain of provided filters.
      def self.filtered_paths(path_hash)
        path_hash.each_pair do |method, filters|
          define_method method.to_sym do |*args|
            filters.inject(self.full_path) do |memo, filter|
              self.send(filter, memo)
            end
          end
        end
      end

      def self.deserialize(line)
        name, path = line.split(/:/)
        if name.nil? || path.nil?
          raise Warp::Dir::Errors::StoreFormatError.new(
            'warprc file may be corrupt, offending line is: ' +
              line, line)
        end
        self.new(name, path)
      end

      filtered_paths absolute_path: %i(quote_spaces),
                     path:          %i(quote_spaces),
                     relative_path: %i(make_relative quote_spaces)

      #
      # Instance Methods
      #
      attr_accessor :full_path, :name

      def initialize(name, full_path)
        raise ArgumentError.new ':name is required' if name.nil?
        raise ArgumentError.new ':full_path is required' if full_path.nil?
        @full_path = Warp::Dir.absolute full_path
        @name      = name.to_sym
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

      def <=>(other)
        name <=> other.name
      end

      def eql?(another)
        return false unless another.is_a?(Warp::Dir::Point)
        %i(name full_path).each do |attribute|
          return false unless send(attribute) == another.send(attribute)
        end
        true
      end

      def serialize
        "#{name}:#{full_path}"
      end

      private

      # Filters that receive a path, and return a possibly decorated path back
      def make_relative(path)
        Warp::Dir.relative(path)
      end

      def quote_spaces(path)
        path =~ /\s+/ ? %Q("#{path}") : path
      end
    end
  end
end
