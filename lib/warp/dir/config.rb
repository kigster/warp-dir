module Warp
  module Dir
    class Config

      DEFAULTS = {
        config: ENV['HOME'] + '/.warprc'
      }

      attr_accessor :config, :params

      def initialize(opts = {})
        options = DEFAULTS.merge(opts)
        self.params = []

        # OK, so this is probably a total overkill :O
        # I just like calling hash members via methods, and I didn't want to load
        # HashieMash because it's big. Real big.
        #
        # For opts passed like this: { force: true } below we will add methods:
        # config.force  config.force= and set the local variable @force to true.
        options.each_pair do |key, value|
          reader   = key.to_sym
          writer   = "#{reader}=".to_sym
          variable = "@#{reader}".to_sym
          # set this value on the the instance of config class
          instance_variable_set(variable, value)
          # add the reader and the writer to this key
          define_singleton_method reader do
            instance_variable_get(variable)
          end
          define_singleton_method writer do |new_value|
            instance_variable_set(variable, new_value)
          end
          self.params << reader
        end
      end

      def [](key)
        config[key]
      end
    end
  end
end
