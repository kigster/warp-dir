module Warp
  module Dir
    class Config

      DEFAULTS = {
        config: ENV['HOME'] + '/.warprc'
      }

      attr_accessor :config, :params

      def initialize(opts)
        options = DEFAULTS.merge(opts)
        self.params = []
        options.each_pair do |key, value|
          reader   = key.to_sym
          writer   = "#{reader}=".to_sym
          variable = "@#{reader}".to_sym
          instance_variable_set(variable, value)
          define_singleton_method reader do
            instance_variable_get(variable)
          end
          define_singleton_method writer do |new_value|
            instance_variable_set(variable, new_value)
          end
          self.params << reader
        end
      end

    end
  end
end
