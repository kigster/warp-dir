require 'warp/dir/command'
require 'warp/dir/formatter'

class Warp::Dir::Command::List < Warp::Dir::Command
  description %q(Print all stored warp points)

  def run(*args)
    formatted_list = ::Warp::Dir::Formatter.new(store).format_store
    on :success do
      message formatted_list.blue.bold
    end
  end
end
