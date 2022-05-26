require_relative 'dir/version'
module Warp
  PROJECT_LIBS = File.dirname(File.absolute_path(__FILE__))
  PROJECT_HOME = "#{PROJECT_LIBS}/../.."

  module Dir
    # tried in order.
    INSTALL_TIME = Time.now
    DOTFILES = %w(.bash_profile .bashrc .profile .bash_login).map{|f| "~/#{f}" }
    SHELL_WRAPPER_FILE = "#{PROJECT_HOME}/bin/warp-dir.bash"
    SHELL_WRAPPER_DEST  = "#{::Dir.home}/.bash_wd"
    SHELL_WRAPPER_REGX  = %r[WarpDir \(v(\d+\.\d+\.\d+)]
    SHELL_WRAPPER_SRCE  = <<-eof
# WarpDir (v#{Warp::Dir::VERSION}, appended on #{INSTALL_TIME}) BEGIN
[[ -f ~/.bash_wd ]] && source ~/.bash_wd
# WarpDir (v#{Warp::Dir::VERSION}, appended on #{INSTALL_TIME}) END
eof
    class << self
      def require_all_from(folder)
        ::Dir.glob("#{Warp::PROJECT_LIBS}#{folder}/*.rb") { |file| Kernel.require file }
      end

      def eval_context?
        ENV['WARP_DIR_SHELL'] == 'yes'
      end

      def pwd
        %x(pwd).chomp.gsub ::Dir.home, '~'
      end

      def relative(path)
        path.gsub ::Dir.home, '~'
      end

      def absolute(path)
        path.gsub '~', ::Dir.home
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
