require 'warp/dir/command'
class Warp::Dir::Command::Help < Warp::Dir::Command
  description 'Show this extremely unhelpful text'

  USAGE = <<EOF
Usage:  wd [ --command ] [ show | list | clean | validate | wipe ]          [ flags ]
      wd [ --command ] [ add  [ -f/--force ] | rm | ls | path ] <point>   [ flags ]
      wd --help | help

Warp Point Commands:
add   <point>   Adds the current directory as a new warp point
rm    <point>   Removes a warp point
show  <point>   Show the path to the warp point
ls    <point>   Show files from tne warp point
path  <point>   Show the path to given warp point

Global Commands:
show            Print warp points to current directory
clean           Remove points warping to nonexistent directories
EOF

  def run
    commander = ::Warp::Dir.commander
    on :success do
      message USAGE
      commander.commands.map(&:command_name).each do |installed_commands|
        message sprintf("    %s\n", commander.find(installed_commands).help)
      end
    end
  end
end
