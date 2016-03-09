#!/usr/bin/env bash

# warp-dir shell wrapper
wd() {
  if [ -z "${warp_dir_exec_installed}" -o "${warp_dir_exec_installed}" == "1" ]; then
    $(which 'warp-dir') 2>&1 > /dev/null
    export warp_dir_exec_installed=$?
  fi

  if [ ${warp_dir_exec_installed} -eq 0 ]; then
    IFS_BACKUP=$IFS
    IFS="+"
    output=$(WARP_DIR_SHELL=yes warp-dir $@ 2>&1)
    code=$?
    if [ $code -eq 127 ]; then
      unset warp_dir_exec_installed
      wd_not_found
    else
      eval ${output}
      IFS=$IFS_BACKUP
    fi
  else
    wd_not_found
  fi
}

wd_not_found() {
    printf "\nWhoops – I can't find 'warp-dir' executable.\n"
    printf "Is the gem properly installed?\n"
    printf "\nTry reinstalling the gem with, for example:\n\n"
    printf "    $ gem install warp-dir --no-wrappers\n"
    printf "    $ hash -r\n"
    printf "    $ warp-dir install [ --dotfile ~/.bashrc ]\n"
}

_wd() {
    local WDWORDS cur

    COMPREPLY=()
    _get_comp_words_by_ref cur

    WDWORDS=$(wd list --no-color  | awk '{ print $1 }')
    COMPREPLY=( $( compgen -W "$WDWORDS" -- "$cur" ) )
}

complete -F _wd wd
