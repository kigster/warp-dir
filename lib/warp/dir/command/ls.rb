require 'warp/dir/command'
module Warp
  module Dir
    class Command
      class LS < Warp::Dir::Command
        class << self
          def description
            %q(Lists directory contents of a warp point without changing current directory)
          end
        end
        def run(flags)
          point = store.find warp_point
          Dir.chdir(point.path)
          flags ||= '-al'
          ls_output = `ls #{flags} #{point.path}`
          happy(ls_output)
        rescue ::Warp::Dir::Errors::PointNotFound => e
          ::Warp::Dir.error message: e.message
        end
      end
    end
  end
end
