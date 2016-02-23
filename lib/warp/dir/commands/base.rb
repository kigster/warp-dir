module Warp
  module Dir
    module Commands
      class Base

        class << self
          def reset!
            @installed_commands = {}
            @validated = false
          end
          def installed_commands
            @installed_commands ||= {}
          end
          def validate!
            return if @validated
            abstract_commands = @installed_commands.keys.select do |key|
              subclass = @installed_commands[key]
              if subclass.respond_to?(:abstract_class?)
                true
              else
                unless subclass.method_defined? :run
                  raise ::Warp::Dir::Errors::InvalidCommand.new("#{subclass} – is not a valid command class")
                else
                  false
                end
              end
            end
            abstract_commands.each {|cmd| @installed_commands.delete(cmd)}
            @validated = true
          end
        end

        attr_reader :store, :warp_point, :path, :point

        def initialize store, warp_point = nil, path = ::Warp::Dir.pwd
          @store = store
          @warp_point = warp_point
          @path = path
          @point = store.find(warp_point) # can be nil
        end

        def self.inherited subclass
          subclass.instance_eval do
            class << self
              def command
                self.name.gsub(/.*::/, '').downcase.to_sym
              end
              def help
                sprintf("%-16s%s", command, self.send(:description))
              end
            end
          end
          self.installed_commands[subclass.command] = subclass
        end
      end
    end
  end
end
