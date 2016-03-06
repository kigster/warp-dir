require_relative 'dir/app/response'
module Warp
  PROJECT = File.dirname(File.absolute_path(__FILE__))
  module Dir
    class << self
      def require_all_from(folder)
        ::Dir.glob(Warp::PROJECT + folder + '/*.rb') { |file| Kernel.require file }
      end

      def pwd
        %x(pwd).gsub ENV['HOME'], '~'
      end

      def relative(path)
        path.gsub ENV['HOME'], '~'
      end

      def absolute(path)
        path.gsub '~', ENV['HOME']
      end

      def default_config
        relative Warp::Dir::Config::DEFAULTS[:warprc]
      end

      def sort_by(collection, field)
        collection.sort { |a, b| a.send(field) <=> b.send(field) }
      end

      # Wrappers

      def commander(*args)
        Module.const_get('Warp::Dir::Commander').instance(*args)
      end

      def store(*args)
        @store ||= Module.const_get('Warp::Dir::Store').singleton(*args)
      end

      def config(*args)
        @config ||= Module.const_get('Warp::Dir::Config').new(*args)
      end


      # @param [Object] type – a symbol: :success, :error, :shell
      # @param [Object] block - a block where response is defined
      # eg.
      #
      # on :success do
      #   code 100
      #   message 'Awesome thanks!'
      # end
      #
      def on(type, &block)
        Warp::Dir::App::Response.instance.type(type).configure(&block)
      end
    end

  end
end

class Object
  def blank?
    self.eql?('') || self.nil?
  end
end

Warp::Dir.require_all_from '/dir/command'
Warp::Dir.require_all_from '/dir'
