require 'warp/dir/command'

class Warp::Dir::Command::Add < Warp::Dir::Command
  description %q(Adds the current directory as a new Warp Point)
  needs_a_point? true
  aliases :new, :save, :store

  def run(*args)
    self.point_path ||= Dir.pwd
    store.insert point_name: point_name, point_path: point_path, overwrite: config.force

    on :success do
      message 'Warp point saved!'
    end
  end
end
