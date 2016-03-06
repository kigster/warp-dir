require 'forwardable'

module Warp
  module Dir
    class Config

      DEFAULTS = {
        warprc: ENV['HOME'] + '/.warprc',
        shell: false,
        force: false,
        debug: false
      }

      attr_accessor :variables

      extend ::Forwardable
      def_delegators :@variables, :size, :<<, :map, :each
      def initialize(opts = {})
        configure(opts)
      end

      def configure(opts = {})
        options = DEFAULTS.merge(opts)

        # Move :config hash key->value to :warprc that is expected by the Config
        if options[:config]
          options[:warprc] = options[:config]
          options.delete(:config)
        end

        self.variables = []

        # OK. I concede. This is very likely a total overkill :O
        # The thing is: I just really like calling hash members via
        # methods, and I didn't want to load HashieMash because
        # it's big. Real big.
        #
        # IRB Session that explains it all:
        #
        # c = Config.new({ foo: "bar", bar: "foo"})
        # => #<Warp::Dir::Config:0x007ff8e39531f0 @variables=[:config, :foo, :bar], @config="/Users/kigster/.warprc", @foo="bar", @bar="foo">
        #  > c.foo              # => "bar"
        #  > c.bar              # => "foo"
        #  > c.bar?             # => true
        #  > c.config           # => "/Users/kigster/.warprc"
        #  > c.color = "red"    # => "red"
        #  > c.color            # => "red"
        #  > c.color?           # => true

        options.each_pair do |variable_name, value|
          self.variables << add_config_variable(variable_name, value)
        end
      end

      # allow syntax @config[:warprc]
      def [](key)
        self.send(key)
      end

      # Dispatches redis operations to master/slaves.
      def method_missing(method, *args, &block)
        if method =~ /=$/
          add_config_variable(method.to_s.gsub(/=$/, ''), *args)
        else
          super
        end
      end

      private

      def add_config_variable(variable_name, value)
        reader   = variable_name.to_sym
        writer   = "#{reader}=".to_sym
        boolean  = "#{reader}?"
        variable = "@#{reader}".to_sym
        # set this value on the the instance of config class
        instance_variable_set(variable, value)
        # add the reader and the writer to this key
        define_singleton_method(reader) { instance_variable_get(variable) }
        define_singleton_method(writer) { |new_value| instance_variable_set(variable, new_value) }
        define_singleton_method(boolean){ !instance_variable_get(variable).nil? }
        reader
      end

    end
  end
end
