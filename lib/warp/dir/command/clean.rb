require 'warp/dir/command'
require 'warp/dir/formatter'

class Warp::Dir::Command::Clean < Warp::Dir::Command
  description %q(Removes any no-longer existing warp points)
  aliases :x

  def run(*)
    removed = store.clean!
    s = self.store
    if removed.empty?
      on :success do
        message 'All entries are valid in your file ' + s.config.warprc.blue + ' are ' + 'valid.'.green
      end
    else
      on :success do
        message "The following no-longer existing points have been removed:\n\n".bold +
                  ::Warp::Dir::Formatter::StoreFormatter.new(removed).format.bold.red
      end
    end
  end
end
