module Warp
  module Dir
    class Store
      attr_accessor :config, :serializer

      def initialize config, serializer_class = SERIALIZERS.values.first
        self.config     = config
        self.serializer = serializer_class.new(self)
        serializer.restore!
      end

      def points
        @points ||= {}
      end

      def add! shortcut, path
        add shortcut, path
        save!
      end

      def add shortcut, path
        points[shortcut] = path
      end

      def save!
        serializer.persist!
      end
    end
  end
end

