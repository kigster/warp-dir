# Warp Directory

[![Build Status](https://travis-ci.org/kigster/warp-dir.svg?branch=master)](https://travis-ci.org/kigster/warp-dir)
[![Code Climate](https://codeclimate.com/github/kigster/warp-dir/badges/gpa.svg)](https://codeclimate.com/github/kigster/warp-dir)
[![Test Coverage](https://codeclimate.com/github/kigster/warp-dir/badges/coverage.svg)](https://codeclimate.com/github/kigster/warp-dir/coverage)
[![Issue Count](https://codeclimate.com/github/kigster/warp-dir/badges/issue_count.svg)](https://codeclimate.com/github/kigster/warp-dir)

<hr/>
[![Gitter](https://img.shields.io/gitter/room/gitterHQ/gitter.svg)](https://gitter.im/kigster/warp-dir)
<hr/>

This is a ruby implementation of the tool 'wd' (warp directory),
[originally written as a zsh module](https://github.com/mfaerevaag/wd)
by [Markus Færevaag](https://github.com/mfaerevaag).

After finding it very useful, but having to switch to `bash` on occasion, I wanted to have a completely
compatible tool that is well tested, and can be extended to do some more interesting things.

Markus kindly offered a ruby version in a [separate branch of this module](https://github.com/mfaerevaag/wd/tree/ruby),
which served as an inspiration for this gem.

The overall concept comes from the realization that when we work on the command line, we

 * often have to deal with a limited number of folders at any given time
 * it would be nice to quickly switch between these folders (which we call __warp points__).
 * it should be easy to add, remove, list, and validate warp points
 * everything should require as few characters as possible :)

Some future extensions could be based on some additional realizations:

 * each folder often represents a project, some of which are managed by `git`
 * eventually we might want to do things across all projects, such as perform group `git pull`,
   or even `git push` etc.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'warp-dir', '~> 1.0 '
```
And then execute:

    $ bundle

Or install it yourself as:

    $ gem install warp-dir --no-ri --no-rdoc
    
After the installation, you will have the `warp-dir` command in the path,
which actually returns (as it's output) commands for the shell to 
interprete. This is why you also need to install a tiny shell function
to wrap this gem's executable.

You can do it using several ways:

    $ warp-dir install [ --file <file> ]

This command will ensure you have the wrapper installed in your ~/.bashrc or ~/.zshrc.
Without the `--file` option, it will install it in both if it finds them. With the 
`--file` option, it will only add the shell function to the file specified.

And after that you should be able to get the helpful message below by typing:

    $ wd help

If the above command returns a properly formatted help like the image below, your setup
is now complete!

## Usage

The usage of the tool is a derived superset of the `ZSH`-based inspiration.

![Image](doc/wd-help-800x710.png)

#### Notable Differences

 * instead of `wd add!` use `wd add -f <point>` (or --force)
 * for now `wd clean` is not supported.
 
## Future Development

I have so many cool ideas about where this can go, that I created a 
[dedicated page](ROADMAP.md) for the discussion of future features.  Please head over
there if you'ld like to participate.

## Development

After checking out the repo, run `bin/setup` to install dependencies.
You can also run `bin/console` for an interactive prompt that will
allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`.
To release a new version, update the version number in `version.rb`, and
then run `bundle exec rake release`, which will create a git tag for the
version, push git commits and tags, and push the `.gem` file
to [rubygems.org](https://rubygems.org).

## Adding New Commands

Just follow the patter in the `lib/warp/dir/commands/` folder, copy and modify
one of the existing commands.  Command class name is used as an actual command.

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/kigster/warp-dir.

## Author

<p>&copy; 2016 Konstantin Gredeskoul, all rights reserved.</p>

## License

This project is distributed under the [MIT License](https://raw.githubusercontent.com/kigster/warp-dir/master/LICENSE).
