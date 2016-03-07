#!/usr/bin/env bash

function wd {
  $(which 'warp-dir') 2>&1 > /dev/null
  have_executable=$?
  if [ ${have_executable} -eq 0 ]; then
    IFS_BACKUP=$IFS
    IFS="+"
    output=$(warp-dir $@ 2>&1)
    code=$?
    eval ${output}
    IFS=$IFS_BACKUP
  else
    printf "\nWhoops – I can't find 'warp-dir' executable.\n"
    printf "Is the gem properly installed? Sometimes it helps to run 'hash -r'.\n"
    printf "\nTry reinstalling the gem with:\n\n"
    printf "    $ gem install warp-dir --no-wrappers\n"
    printf "    $ hash -r\n"
    printf "    $ warp-dir install\n"
  fi
}
