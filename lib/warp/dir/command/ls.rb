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
          point = store.find_point(point_name)
          Dir.chdir(point.point_path)
          flags = '-al' unless flags
          ls_output = `ls #{flags} #{point.path}`
          happy(ls_output)
        end
      end
    end
  end
end
