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

      @@semaphore = Mutex.new
      # Here we are reimplementing Singleton, but with a twist: we need to be able
      class << self
        attr_accessor :instance

        def singleton(*args, &block)
          return self.instance if self.instance
          @@semaphore.synchronize do
            self.instance ||= new(*args, &block)
          end
        end

        private
        def new(*args, &block)
          super
        end
      end

      extend Forwardable
      def_delegators :@points_collection, :size, :clear, :each, :map
      def_delegators :@config, :warprc, :shell

      attr_reader :config, :serializer, :points_collection

      def initialize(config, serializer_class = Warp::Dir::Serializer.default)
        @config            = config
        serializer_class   ||= Warp::Dir::Serializer.default
        @serializer        = serializer_class.new(self)
        @points_collection = Set.new
        self.serializer.restore!
      end

      def [](name)
        find_point(name)
      end

      def <<(value)
        raise ArgumentError.new("#{value} is not a Point") unless value.is_a?(Point)
        self.add(value)
      end

      def remove(name)
        point = name.is_a?(Warp::Dir::Point) ? name : self[name]
        self.points_collection.delete(point) if point
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

      def save!
        serializer.persist!
      end

      # a version of add that save right after.
      def insert(*args)
        add(*args)
        save!
      end

      def add_by_name(warp_point_name, path, *args)
        if !(warp_point_name) || !(path)
          raise ArgumentError.new('invalid arguments')
        end
        add(Warp::Dir::Point.new(warp_point_name, path), *args)
      end

      # add to memory representation only
      def add(point, overwrite: false)
        # Three use-cases here.
        # if we found this WarpPoint by name, and it's path is different from the incoming...
        existing = begin
          self[point]
        rescue Warp::Dir::Errors::PointNotFound
          nil
        end

        if existing.eql?(point) # found, but it's identical
          return
        elsif existing # found, but it's different
          if overwrite # replace it
            replace(point, existing)
          else # reject it
            raise Warp::Dir::Errors::PointAlreadyExists.new(point)
          end
        else # no lookup found
          self.points_collection << point # add it
        end
      end

      def replace(point, existing_point = nil)
        existing_point ||= self[point.name]
        if existing_point && existing_point.path != point.path
          remove(existing_point)
        end
        self.points_collection.add(point) # new warp point
        point
      end
    end
  end
end
