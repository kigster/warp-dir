require 'warp/dir/command'
class Warp::Dir::Command
  class Remove < Warp::Dir::Command
    description %q(Removes a given warp point from the database)

    def run
      store.remove point_name
      on :success do
        message "Warp point #{point_name.yellow} has been removed."
      end
    end
  end
end
