require_relative '../errors'
require_relative '../../dir'
module Warp
  module Dir
    module Serializer
      class Dotfile < Base

        def restore!
          File.open(Warp::Dir.absolute(config.config), "r") do |f|
            f.each_line do |line|
              line = line.chomp
              next if line.blank?
              name, path = line.split(/:/)
              if name.nil? || path.nil?
                raise Warp::Dir::Errors::StoreFormatError.new("Corrupt data file, line [#{line}]", line)
              end
              store.add name, path
            end
          end
        end

        def persist!
          File.open(config.config, 'w') do |file|
            buffer = ""
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


