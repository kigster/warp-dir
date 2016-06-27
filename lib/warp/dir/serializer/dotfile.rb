require_relative '../errors'
require_relative '../../dir'
require_relative 'base'
module Warp
  module Dir
    module Serializer
      # Serializer only assumes that Points can serialize themselves
      # or deserialize themselves to/from a one-line text format.
      class Dotfile < Base

        def warprc_file_path
          Warp::Dir.absolute(config.warprc)
        end

        def restore!
          unless File.exist?(warprc_file_path)
            STDERR.puts "No warprc file found in the path #{warprc_file_path}" if config.debug
            return
          end
          File.open(warprc_file_path, 'r') do |f|
            f.each_line do |line|
              line = line.chomp
              next if line.blank?
              line.gsub!(/["']/,'') # remove any quotes that may have been inserted
              store.add(point: Warp::Dir::Point.deserialize(line))
            end
          end
        end

        def persist!
          File.open(warprc_file_path, 'wt') do |file|
            buffer = ''
            store.points.each do |point|
              buffer << "#{point.serialize}\n"
            end
            file.write(buffer)
          end
        end
      end
    end
  end
end
