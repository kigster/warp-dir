module Warp
  PROJECT = File.dirname(File.absolute_path(__FILE__))
  module Dir
    def self.require_all_from folder
      ::Dir.glob(Warp::PROJECT + folder + '/*.rb') {|file| Kernel.require file }
    end
  end
end

Warp::Dir.require_all_from '/dir'
