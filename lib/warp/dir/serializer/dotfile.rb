require_relative '../errors'
require_relative '../../dir'
module Warp
  module Dir
    module Serializer
      class Dotfile < Base

        def restore!
          File.open(Warp::Dir.absolute(config.warprc), "r") do |f|
            f.each_line do |line|
              line = line.chomp
              next if line.blank?
              name, path = line.split(/:/)
              if name.nil? || path.nil?
                raise Warp::Dir::Errors::StoreFormatError.new("File may be corrupt - #{config.warprc}:#{line}", line)
              end
              store.add point_name: name, point_path: path
            end
          end
        end

        def persist!
          File.open(Warp::Dir.absolute(config.warprc), 'w') do |file|
            buffer = ''
            store.points.each do |point|
              buffer << "#{point.name}:#{point.relative_path}\n"
            end
            file.write(buffer)
          end
        end
      end
    end
  end
end


