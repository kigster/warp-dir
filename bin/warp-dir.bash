#!/usr/bin/env bash

# warp-dir auto installer

wd() {
  executable=warp-dir
  which warp-dir 2>&1 > /dev/null
  have_executable=0
  if [ ${have_executable} -eq 0 ]; then
    ifs_backup=$IFS
    IFS="+"
    output=$(warp-dir $@ 2>&1)
    code=$?
    eval ${output}
    IFS=$ifc_backup
  else
    echo "Can't find warp-dir executable!"
  fi
}


