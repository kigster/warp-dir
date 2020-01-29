require_relative 'point'
require_relative 'errors'
require_relative 'serializer'
require 'forwardable'

module Warp
  module Dir

    # We want to keep around only one store, so we follow the Singleton patter.
    # Due to us wanting to pass parameters to the singleton class's #new method,
    # using standard Singleton becomes more hassle than it's worth.
    class Store
      extend Forwardable

      def_delegators :@points_collection, :size, :clear, :each, :map
      def_delegators :@config, :warprc, :shell

      attr_reader :config, :serializer, :points_collection

      def initialize(config, serializer_class = Warp::Dir::Serializer.default)
        @config            = config
        serializer_class   ||= Warp::Dir::Serializer.default
        @serializer        = serializer_class.new(self)
        restore!
      end

      def restore!
        @points_collection = Set.new
        self.serializer.restore!
      end

      def [](name)
        find_point(name)
      end

      def first
        points_collection.to_a.sort.first
      end

      def last
        points_collection.to_a.sort.last
      end

      def <<(value)
        raise ArgumentError.new("#{value} is not a Point") unless value.is_a?(Point)
        self.add(point: value)
      end

      def remove(point_name: nil)
        point = point_name.is_a?(Warp::Dir::Point) ? point_name : self[point_name]
        self.points_collection.delete(point) if point
        save!
      end

      def points
        points_collection.to_a
      end

      def find_point(name_or_point)
        return if name_or_point.nil?
        result = if name_or_point.is_a?(Warp::Dir::Point)
                   self.find_point(name_or_point.name)
                 else
                   matching_set = self.points_collection.classify { |p| p.name.to_sym }[name_or_point.to_sym]
                   (matching_set && !matching_set.empty?) ? matching_set.first : nil
                 end
        raise ::Warp::Dir::Errors::PointNotFound.new(name_or_point) unless result
        result
      end

      def clean!
        points_collection.select(&:missing?).tap do |p|
          points_collection.reject!(&:missing?)
          save!
        end
      end

      def save!
        serializer.persist!
      end

      # a version of add that save right after.
      def insert(**opts)
        add(**opts)
        save!
      end

      # add to memory representation only
      def add(point: nil,
              point_name: nil,
              point_path: nil,
              overwrite: false)
        unless point
          if !(point_name && point_path)
            raise ArgumentError.new('invalid arguments')
          end
          point = Warp::Dir::Point.new(point_name, point_path)
        end

        # Three use-cases here.
        # if we found this WarpPoint by name, and it's path is different from the incoming...
        existing = begin
          self[point]
        rescue Warp::Dir::Errors::PointNotFound
          nil
        end

        if existing.eql?(point) # found, but it's identical
          if config.debug
            puts "Point being added #{point} is identical to existing #{existing}, ignore."
          end
          return
        elsif existing # found, but it's different
          if overwrite # replace it
            if config.debug
             puts "Point being added #{point} is replacing the existing #{existing}."
            end
            replace(point, existing)
          else # reject it
            if config.debug
             puts "Point being added #{point} already exists, but no overwrite was set"
            end
            raise Warp::Dir::Errors::PointAlreadyExists.new(point)
          end
        else # no lookup found
          self.points_collection << point # add it
        end
      end

      def replace(point, existing_point)
        remove(point_name: existing_point)
        insert(point: point)
      end
    end
  end
end
