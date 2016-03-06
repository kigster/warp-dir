require 'warp/dir/command'
class Warp::Dir::Command
  class Remove < Warp::Dir::Command
    description %q(Removes a given warp point from the database)
    needs_a_point? true
    aliases :rm, :delete

    def run(*args)
      point_name = self.point_name
      store.remove point_name: point_name
      on :success do
        message "Warp point #{point_name.to_s.yellow} has been removed."
      end
    end
  end
end
