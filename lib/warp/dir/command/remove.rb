require 'warp/dir/command'
class Warp::Dir::Command
  class Remove < Warp::Dir::Command
    description %q(Removes a given warp point from the database)

    def run
      # store.find(point_name).destroy
      store.delete point_name
      on :success do
        message 'Warp point deleted.'
      end
    end
  end
end
