module Warp
  PROJECT_LIBS = File.dirname(File.absolute_path(__FILE__))
  PROJECT_HOME = PROJECT_LIBS + '/../..'

  module Dir
    # tried in order.
    DOTFILES = %w(~/.bashrc ~/.bash_profile ~/.profile)

    SHELL_WRAPPER = "#{PROJECT_HOME}/bin/warp-dir.bash"

    class << self
      def require_all_from(folder)
        ::Dir.glob(Warp::PROJECT_LIBS + folder + '/*.rb') { |file| Kernel.require file }
      end

      def eval_context?
        ENV['WARP_DIR_SHELL'] == 'yes'
      end

      def pwd
        %x(pwd).chomp.gsub ENV['HOME'], '~'
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

    end
    end
end

Warp::Dir.require_all_from '/dir'
Warp::Dir.require_all_from '/dir/command'

module Warp
  module Dir
    class << self
      def on(type, &block)
        Warp::Dir::App::Response.new.type(type).configure(&block)
      end

      def commander
        ::Warp::Dir::Commander.instance
      end
    end

  end
end

class Object
  def blank?
    self.eql?('') || self.nil?
  end
end

