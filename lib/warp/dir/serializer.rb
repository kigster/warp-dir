module Warp
  module Dir
    SERIALIZERS = {}
    module Serializer
      def self.default
        SERIALIZERS.values.first
      end
    end
  end
end

Warp::Dir.require_all_from '/dir/serializer'

raise 'No concrete serializer implementations were found' if Warp::Dir::SERIALIZERS.empty?
