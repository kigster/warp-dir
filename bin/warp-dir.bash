#!/usr/bin/env bash

# warp-dir shell wrapper
wd() {
  if [ -z "${warp_dir_exec_installed}" ]; then
    printf "checking if the warp-dir executable is installed... "
    $(which 'warp-dir') 2>&1 > /dev/null
    export warp_dir_exec_installed=$?
    if [ ${warp_dir_exec_installed} -eq 0 ]; then
      printf "yep! You are super awesome :)\n\n"
    fi
  fi

  if [ ${warp_dir_exec_installed} -eq 0 ]; then
    IFS_BACKUP=$IFS
    IFS="+"
    output=$(WARP_DIR_SHELL=yes warp-dir $@ 2>&1)
    code=$?
    eval ${output}
    IFS=$IFS_BACKUP
  else
    printf "\nWhoops – I can't find 'warp-dir' executable.\n"
    printf "Is the gem properly installed?\n"
    printf "\nTry reinstalling the gem with, for example:\n\n"
    printf "    $ gem install warp-dir --no-wrappers\n"
    printf "    $ hash -r\n"
    printf "    $ warp-dir install [ --dotfile ~/.bashrc ]\n"
  fi
}
