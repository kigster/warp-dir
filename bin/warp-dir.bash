#!/usr/bin/env bash

wd() {
	cmd=$(warp-dir $*)
	eval $cmd
}
