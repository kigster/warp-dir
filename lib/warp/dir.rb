module Warp
  PROJECT = File.dirname(File.absolute_path(__FILE__))
  module Dir
    def self.require_all_from folder
      ::Dir.glob(Warp::PROJECT + folder + '/*.rb') { |file| Kernel.require file }
    end

    def self.pwd
      ENV['PWD'].gsub ENV['HOME'], '~'
    end

    def self.canonical path
      path.gsub ENV['HOME'], '~'
    end

  end
end

class Object
  def blank?
    self.eql?("") || self.nil?
  end
end

Warp::Dir.require_all_from '/dir'
