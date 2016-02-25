module Warp
  PROJECT = File.dirname(File.absolute_path(__FILE__))
  module Dir
    def self.require_all_from folder
      ::Dir.glob(Warp::PROJECT + folder + '/*.rb') { |file| Kernel.require file }
    end

    def self.pwd
      %x(pwd).gsub ENV['HOME'], '~'
    end

    def self.relative path
      path.gsub ENV['HOME'], '~'
    end

    def self.absolute path
      path.gsub '~', ENV['HOME']
    end

    def self.default_config
      relative Warp::Dir::Config::DEFAULTS[:warprc]
    end

    def self.sort_by(collection, field)
      collection.sort { |a, b| a.send(field) <=> b.send(field) }
    end
  end
end

class Object
  def blank?
    self.eql?("") || self.nil?
  end
end

Warp::Dir.require_all_from '/dir/command'
Warp::Dir.require_all_from '/dir'
