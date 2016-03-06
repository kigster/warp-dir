require 'warp/dir/command'
class Warp::Dir::Command::Help < Warp::Dir::Command
  description 'Show this extremely unhelpful text'

  USAGE = <<EOF
#{"Usage:".bold.green}  wd [ --command ] [ show | list | clean | validate | wipe ]          [ flags ]
        wd [ --command ] [ add  [ -f/--force ] | rm | ls | path ] <point>   [ flags ]
        wd --help | help

#{"Warp Point Commands:".bold.green}

  #{"add".yellow}   <point>   #{"Adds the current directory as a new warp point".bold.blue}
  #{"rm".yellow}    <point>   #{"Removes a warp point".bold.blue}
  #{"show".yellow}  <point>   #{"Show the path to the warp point".bold.blue}
  #{"ls".yellow}    <point>   #{"Show files from tne warp point".bold.blue}
  #{"path".yellow}  <point>   #{"Show the path to given warp point".bold.blue}

#{"Global Commands:".bold.green}
EOF

  def run
    commander = ::Warp::Dir.commander
    on :success do
      message USAGE
      commander.commands.map(&:command_name).each do |installed_commands|
        message sprintf("  %s\n", commander.find(installed_commands).help)
      end
    end
  end
end
