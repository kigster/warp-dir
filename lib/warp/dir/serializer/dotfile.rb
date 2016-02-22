module Warp
  module Dir
    module Serializer
      class Dotfile < Base

        def restore!
          File.open(config.dotfile, "r") do |f|
            f.each_line do |line|
              name, path = line.chomp.split(/:/)
              store.add name, path
            end
          end
        end

        def persist!
          File.open(config.dotfile, 'w') do |file|
            buffer = "\n"
            store.points.each_pair do |name, path|
              buffer << "#{name}:#{path}\n"
            end
            file.write(buffer + "\n")
          end
        end
      end
    end
  end
end


