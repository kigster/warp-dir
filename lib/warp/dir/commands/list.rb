require_relative 'base'
module Warp
  module Dir
    module Commands
      class List < Base
        class << self
          def description
            %q(Print all stored warp points)
          end
        end
        def run
          out = ""
          store.points.each do |point|
            out << "printf \"#{point}\\n\"; "
          end
          puts out
        end
      end
    end
  end
end
