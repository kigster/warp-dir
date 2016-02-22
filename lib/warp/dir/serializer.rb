module Warp
  module Dir
    SERIALIZERS = {}
    module Serializer
    end
  end
end

Warp::Dir.require_all_from '/dir/serializer'

raise 'No concrete serializer implementations were found' if Warp::Dir::SERIALIZERS.empty?
