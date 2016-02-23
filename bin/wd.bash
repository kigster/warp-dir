#!/usr/bin/env bash

wd() {
	cd $(warp-dir $*)
}

wd $*
