require_relative 'point'
require_relative 'errors'
require 'forwardable'
module Warp
  module Dir
    class Store
      attr_accessor :config, :serializer
      attr_reader :points_collection

      extend Forwardable
      #________________________________________________________________________
      #
      # Very Important – Methods Delegated to the Collection
      #________________________________________________________________________
      #
      def_delegators :@points_collection, :[], :formatted, :add
      #________________________________________________________________________

      def initialize config, serializer_class = SERIALIZERS.values.first
        self.config        = config
        self.serializer    = serializer_class.new(self)
        @points_collection = Warp::Dir::Point::Collection.new
        serializer.restore!
      end

      def points
        points_collection.to_a
      end

      def path name
        (p = points_collection[name]) ? p.path : nil
      end

      def save!
        serializer.persist!
      end
    end
  end
end
