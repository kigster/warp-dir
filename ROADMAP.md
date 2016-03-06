# Warp Directory – Future Roadmap

[![Gitter](https://img.shields.io/gitter/room/gitterHQ/gitter.svg)](https://gitter.im/kigster/warp-dir)

Here I'd like to document various ideas and feature requests from myself and others.

## Simplify Interface

Questionable value, but this sort of interface appear a bit more consistent. 

Still I am not sure I want to type `wd -j proj` or `wd -a proj` instead of `wd proj` and `wd add proj`...
 
```bash
  wd -j/--jump   point
  wd -a/--add    point
  wd -r/--remove point
  wd -l/--ls     point
  wd -p/--path   point

  wd -L/--list
  wd -C/--clean
  wd -S/--scan           # report whether points exist on the file system
```  

## Run Commands In A Warp Point

Pass an arbitrary command to execute, and return back to CWD.

```bash
  wd proj -x/--exec -- "command"      
```

## Group Commands

Create a group of several warp points:

```bash
  wd -g/--group group1 -d/--define "point1,point2,...,pointN"
  wd -g/--group group1 -r/--remove  point1  # remove a point from the group
  wd -g/--group group1 -a/--add     point1  # add a point to the group
```

Execute command in all warp points of the group:

```bash
  wd -x/--exec [ -g/--group group ] [ -r/--return-code ] -- command     
```

As above, until one returns non-blank output (ie, search).
If -r is passed, it stops at the first return code of value passed, or 0

```bash
  wd -f/--find [ -g/--group group ] [ -r/--return-code ] -- command     
```

As above, until one returns blank output. If -r is passed, it stops at the first 
return code not equal to the value passed, or 0

```bash
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
  wd --all --group project-group --return-code -- bundle exec rspec
```

## Networking

Can we go across SSH?

```bash
  wd add proj kig@remote.server.com:~/workspace/proj
  wd ls proj 
  wd proj       
```
This then establishes and SSH connection to the server and logs you into the shell. Should be pretty easy, I think :) 

## What Else?

Sky is the limit :)  Well, and the black hole that the warp directory is :)
