require 'warp/dir/errors'
module Warp
  module Dir
    module Commands
      class Base

        class << self
          def installed_commands
            @installed_commands ||= {}
          end
          def validate!
            @installed_commands.values.each do |subclass|
              unless subclass.method_defined? :run
                raise Warp::Dir::Errors::InvalidCommand.new("Class #{subclass} is not a valid command")
              end
            end
          end
        end

        attr_reader :store

        def initialize store
          @store = store
        end

        def self.inherited subclass
          shortname = subclass.name.gsub(/.*::/, '').downcase
          self.installed_commands[shortname.to_sym] = subclass
        end
      end
    end
  end
end
