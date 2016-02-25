#!/usr/bin/env bash

wd() {
  stderr=/tmp/wd.$$
  trap wd-done EXIT
  cmd="warp-dir $*"
  out="$(${cmd} 2>&1)"
  result=$?
  if [ $result -ne 0 ] ; then
    printf "${txtred}Error occured, return is ${result}${txtwht}\n"
    printf "${txtylw}$(cat $stderr)"
    return
  fi
  printf "${txtgrn}${txtbld}Command:\n${txtwht}"
  printf "$cmd\n"
  printf "${txtblu}${txtbld}Output:\n${txtwht}"
  printf "$out\n"
  eval "$out"
}