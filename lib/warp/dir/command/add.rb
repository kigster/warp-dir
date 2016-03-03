require 'warp/dir/command'
class Warp::Dir::Command::Add < Warp::Dir::Command
  description %q(Adds the current directory as a new warp point)

  def run
    store.add_by_name point_name, point_path
    store.save!
    on :success do
      message 'Warp point saved!'
    end
  end
end
