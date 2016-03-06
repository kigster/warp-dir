#!/usr/bin/env bash

wd() {
  ifs_backup=$IFS
  IFS="+" # this is needed so that the tabulated output does not collapse
  output=$(warp-dir $@ 2>&1)
  code=$?
  eval ${output}
  IFS=$ifc_backup
}
