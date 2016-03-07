require 'warp/dir/command'

class Warp::Dir::Command::Install < Warp::Dir::Command
  description %q(Installs warp-dir shell wrapper in your ~/.bashrc)
  needs_a_point? false

  def run(*args)
    files = if config.respond_to?(:dotfile) && config[:dotfile]
              config[:dotfile].split(',')
            else
              %w(~/.bashrc ~/.zshrc ~/.profile)
            end
    installed = []
    files.each do |dotfile|
      file = ::Warp::Dir.absolute(dotfile)
      if File.exist?(file)
        matches = `egrep 'wd()|warp-dir' #{file}`
        if matches.nil? || matches == '' || config[:force]
          File.open(file, 'a') do |f|
            f.puts <<-EOF
# warp-dir auto installer
wd() {
  if [ -n "$(which warp-dir)" ]; then
    ifs_backup=$IFS
    IFS="+" # this is needed so that the tabulated output does not collapse
    output=$(warp-dir $@ 2>&1)
    code=$?
    eval ${output}
    IFS=$ifc_backup
  else
    echo "Please install the gem, so that 'warp-dir' executable is in the path."
  fi
}
            EOF
          end
          installed << file
        end
      end
    end
    on :success do
      message "Shell support is installed in #{installed.join(', ')}!"
    end
  end
end
