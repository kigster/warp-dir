# Warp Directory

[![Build Status](https://travis-ci.org/kigster/warp-dir.svg?branch=master)](https://travis-ci.org/kigster/warp-dir)
[![Code Climate](https://codeclimate.com/github/kigster/warp-dir/badges/gpa.svg)](https://codeclimate.com/github/kigster/warp-dir)
[![Gitter](https://img.shields.io/gitter/room/gitterHQ/gitter.svg)](https://gitter.im/kigster/warp-dir)

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
gem 'warp-dir'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install warp-dir

## Usage

The usage of the tool is a derived superset of the `ZSH`-based inspiration.

```bash
  > wd --help 
  Usage: wd [ show | list | clean | validate | wipe ]          [ flags ] 
         wd [ add  [ -f/--force ] | rm | ls | path ] <point>   [ flags ]
         wd -v/-
         wd help
         
  Where:
    Flags           -c/--config file    # default is ~/.warprc
                    -q/--quiet          # suppress all output
                    -n/--dry-run        # just display the commands
                    -f/--force          # overwrite if exists
                    -C/--no-color       # do not print color output
                    
  Warp Point Commands:
    add   <point>   Adds the current directory as a new warp point
    rm    <point>   Removes a warp point
    show  <point>   Show the path to the warp point
    ls    <point>   Show files from tne warp point
    path  <point>   Show the path to given warp point
  
  Global Commands:
    show            Print warp points to current directory
    list            Print all stored warp points
    clean           Remove points warping to nonexistent directories
    help            Show this extremely unhelpful text

```

#### Notable Differenc

 * instead of `wd add!` use `wd add -f <point>` (or --force)
 * instead of `wd clean!` use `wd clean`
 * run `wd validate` to see what will be removed by `clean`.

## Future Features

### Simplify Interface

```bash
  wd -a/--add    point1
  wd -r/--remove point1
  wd -l/--ls     point1
  wd -p/--path   point1
  
  wd -L/--list
  wd -C/--clean
  wd -S/--scan           # report whether points exist on the file system
```  

### Run Commands

```bash
  wd proj -x/--exec -- "command"    # pass an arbitrary command to execute, and return back to CWD  
```

### Group Commands

```bash
  # create a group of several warp points
  wd -g/--group group1 -d/--define "point1,point2,...,pointN"
  wd -g/--group group1 --remove point1  # remove a point from the group
  wd -g/--group group1 --add    point1  # add a point to the group
  
  # execute command in all warp points of the group
  wd -x/--exec [ -g/--group group ] [ -r/--return-code ] -- command     

  # as above, until one returns non-blank output (ie, search)
  # if -r is passed, it stops at the first return code of value passed, or 0
  wd -f/--find [ -g/--group group ] [ -r/--return-code ] -- command     
  
  # as above, until one returns blank output
  # if -r is passed, it stops at the first return code not equal to the value passed, or 0
  wd -a/--all  [ -g/--group group ] [ -r/--return-code ] -- command        
  
```

The idea here is that you can group several warp points together, and then
execute a command in all of them. You could use to:

 * search for a specific file in one of the project repos – you expect to exist in 
   only one of them, and so you want the search to stop once found (indicated
   by return code equal to 1):
 
```bash
  wd --find --group project-group --return-code=1 -- \
      find . -name .aws-credentials.lol
```

 * you want to run rspec in all projects of the group, and stop at the 
   first non-zero return: 

```bash
  wd --all --group project-group --return-code \
      'bundle exec rspec'
```
  
## Development

After checking out the repo, run `bin/setup` to install dependencies. 
You can also run `bin/console` for an interactive prompt that will 
allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. 
To release a new version, update the version number in `version.rb`, and 
then run `bundle exec rake release`, which will create a git tag for the 
version, push git commits and tags, and push the `.gem` file 
to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/kigster/warp-dir.

## Author

<p>&copy; 2016 Konstantin Gredeskoul, all rights reserved.</p>

## License

This project is distributed under the [MIT License](https://raw.githubusercontent.com/kigster/warp-dir/master/LICENSE).
