#!/bin/bash
color() (
    set -o pipefail
    "$@" 2>&1 1>&3 | sed $'s/.*/\e[31m & \e[m/' >&2
)
3>&1

  f1() {
    echo yes
    echo error >&2
}

color date


color date -@