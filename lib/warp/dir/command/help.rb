require 'warp/dir/command'
require 'warp/dir/command/install'
class Warp::Dir::Command::Help < Warp::Dir::Command
  description 'Show this extremely unhelpful text'
  aliases :wtf


  def run(opts, flags = [])
    commander = ::Warp::Dir.commander
    cmd = self
    on :success do
      message USAGE
      message ' '
      message 'Warp Point Commands:'.bold.green
      message ' '
      message cmd.commands_needing_points(commander, needing_point: true)
      message ' '
      message 'Global Commands:'.bold.green
      message ' '
      message cmd.commands_needing_points(commander, needing_point: false)
      message EXAMPLES
      message INSTALLATION
      message opts.to_s
    end
  end

  def commands_needing_points(commander,
                              needing_point: true)
    help = ''
    commander.
      commands.
      select{|cmd| needing_point ? cmd.needs_a_point? : !cmd.needs_a_point? }.
      map(&:command_name).each do |installed_commands|
      help << sprintf("  %s\n", commander.find(installed_commands).help)
    end
    help
  end

  USAGE = <<EOF

#{"Usage:".bold.green}  wd [ --command ] [ list | help ] [ wd-flags ]
        wd [ --command ] [ [ warp ] | add  [-f] | rm | ls ] [ wd flags ] <point> -- [ cmd-flags ]
        wd --help | help
EOF

  EXAMPLES = <<EOF

#{'Examples'.bold.green}
       wd add proj    # add current directory as a warp point
       wd ~/          # wd works just like 'cd' for regular folders
       wd proj        # jumps to proj
       wd list        # lists all 'bookmarked' points
       wd rm proj     # removes proj
EOF

  if ::Warp::Dir::Command::Install.wrapper_installed?
    INSTALLATION = <<EOF

#{'Installation'.bold.green}
    It appears that you already have a wrapper installed in one of the default
    shell init files (#{::Warp::Dir::DOTFILES.join(', ')}).

    Which means that 'wd' should be working on your system.  If not, edit your
    shell init file, remove any lines related to warp-dir gem, and then reinstall:

    #{'wd install [ --dotfile <filename> ]'.bold.green}

    If you experience any problem, please log an issue at:
    https://github.com/kigster/warp-dir/issues
EOF
  else
    INSTALLATION = <<EOF

#{'Installation'.bold.green}
    In order for you to start warping all around, you must install the shell wrapper which
    calls into the ruby to do the job. Shell wrapper function is required in order to
    change directory in the outer shell (parent process). Do not worry about this if you
    do not understand it, but please run this command:

    #{'wd install [ --dotfile <filename> ]'.bold.green}

    This command will ensure you have the wrapper installed in your ~/.bashrc or ~/.zshrc
    files. Once installed, just restart your shell!

    If you experience any problem, please log an issue at:
    https://github.com/kigster/warp-dir/issues
EOF
  end

end
