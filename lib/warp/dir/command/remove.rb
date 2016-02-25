require 'warp/dir/command'
module Warp
  module Dir
    class Command
      class Remove < Warp::Dir::Command
        class << self
          def description
            %q(Removes a given warp point from the database)
          end
        end
        def run
          store.delete warp_point
        rescue ::Warp::Dir::Errors::PointNotFound => e
          ::Warp::Dir.error message: e.message.gsub(%r{#{e.class.name}}, '')
        end
      end
    end
  end
end
