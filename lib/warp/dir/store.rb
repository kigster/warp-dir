require_relative 'point'
require_relative 'errors'
module Warp
  module Dir
    class Store
      attr_accessor :config, :serializer
      attr_reader :points_list, :points_map

      def initialize config, serializer_class = SERIALIZERS.values.first
        self.config     = config
        self.serializer = serializer_class.new(self)
        @points_list    = []
        @points_map     = {}
        serializer.restore!
      end

      def [] name
        point = (name =~ /^[0-9]+$/ ? points_list[name] : points_map[name])
        point.is_a?(Warp::Dir::Point) ? point.relative_path : nil
      end

      def points
        self.points_list.dup
      end

      def add(name, path)
        p = Warp::Dir::Point.new(name, path)
        return if self[name].eql?(p.relative_path)
        raise Warp::Dir::Errors::PointAlreadyExists.new(p) if self[name]
        points_list << p
        points_map[p.name] = p
      end

      def find(name)
        points_map[name]
      end

      def save *args
        add *args
        save!
      end

      def save!
        serializer.persist!
      end
    end
  end
end
