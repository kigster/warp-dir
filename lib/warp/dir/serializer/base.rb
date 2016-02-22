module Warp
  module Dir
    module Serializer
      class Base
        attr_accessor :store

        def initialize store
          self.store = store
        end

        def config
          self.store.config
        end

        def self.inherited subclass
          Warp::Dir::SERIALIZERS[subclass.name] = subclass
        end

        #
        # restore method should read the values from somewhere (i.e. database?)
        # and perform the following operation:
        #
        # for each [ shortcut, path ] do
        #   self.store.add(shortcut, path)
        # end

        def restore!
          raise NotImplementedError.new('Abstract Method')
        end

        #
        # save shortcuts to the persistence layer
        #
        # store.points.each_pair |shortcut, path| do
        #   save(shortcut, path)
        # end
        def persist!
          raise NotImplementedError.new('Abstract Method')
        end
      end
    end
  end
end
