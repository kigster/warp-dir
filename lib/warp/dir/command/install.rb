require 'warp/dir'
require 'warp/dir/command'
require 'fileutils'
class Warp::Dir::Command::Install < Warp::Dir::Command
  description %q(Installs warp-dir shell wrapper in your ~/.bashrc)
  needs_a_point? false

  attr_accessor :installed, :existing, :wrapper, :shell_init_files

# SHELL_WRAPPER_FILE
# SHELL_WRAPPER_DEST
# SHELL_WRAPPER_REGX
# SHELL_WRAPPER_SRCE

  class << self
    def wrapper_installed?
      ::Warp::Dir::DOTFILES.any?{ |file| already_installed?(file) }
    end

    def already_installed?(file_path)
      path = ::Warp::Dir.absolute(file_path)
      matches = if File.exists?(path)
                  File.open path do |file|
                    file.find { |line| line =~ ::Warp::Dir::SHELL_WRAPPER_REGX }
                  end
                end
      matches
    end
  end

  def initialize(*args)
    self.installed        = []
    self.existing         = []
    self.wrapper          = ::Warp::Dir::SHELL_WRAPPER_SRCE
    self.shell_init_files = ::Warp::Dir::DOTFILES
    super(*args)
  end

  def run(*args)
    self.shell_init_files = config[:dotfile].split(',') if config[:dotfile]
    self.shell_init_files.any? { |dotfile| append_wrapper_to(dotfile) }

    # Overwrites if already there
    install_bash_wd

    local_existing    = self.existing
    local_installed   = self.installed
    local_shell_files = self.shell_init_files

    if installed.empty?
      if existing.empty?
        on :error do
          if local_shell_files.size > 1 then
            message "Shell init files #{local_shell_files.join(', ').yellow.bold} were not found on the filesystem.".red
          else
            message "Shell init file #{local_shell_files.join(', ').yellow.bold} was not found on the filesystem.".red
          end
        end
      else
        on :error do
          message 'Looks like you already have shell support installed.'.red
          message "#{local_existing.join(', ').yellow.bold} already warp-dir definition. Use --force to override."
        end
      end
    else
      on :success do
        message 'Shell support is installed in the following files:'.green.bold
        message "#{local_installed.join(', ')}".bold.yellow
      end
    end
  end

  private

  def install_bash_wd
    source = File.read(::Warp::Dir::SHELL_WRAPPER_FILE)
    source.gsub!(/%WARP-DIR%/, "WarpDir (v#{::Warp::Dir::VERSION})")
    File.open(::Warp::Dir::SHELL_WRAPPER_DEST, 'w') do |file|
      file.puts source
    end
  end

  def append_wrapper_to(shell_init_file)
    file          = ::Warp::Dir.absolute(shell_init_file)
    pre_installed = self.class.already_installed?(file)
    self.existing << file if pre_installed
    if File.exists?(file)
      if !pre_installed || config[:force]
        source = File.read(file)
        source.gsub!(/# WarpDir.*BEGIN\n.*\n# WarpDir.*END/, '')
        File.open(file, 'w') do |f|
          f.write source
          f.write wrapper
        end
        self.installed << shell_init_file
      end
    end
  end

end
