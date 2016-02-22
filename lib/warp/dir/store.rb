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
        name =~ /^[0-9]+$/ ? points_list[name]&.relative_path : points_map[name]&.relative_path
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

