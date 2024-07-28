#!/usr/bin/env bash

DM_SETTINGS=(
    -i
    -l  '40'
    -b
    -x  '20'
    -y  '20'
    -w  '800'
    -sb '#222222'
    -sf '#00FF00'
    -nf '#AAAAAA'
    -nb '#000000'
    -fn 'InputMono:style=Regular:pixelsize=12:antialias=true:autohint=true'
    -p  '>'
)

function main() {
    if [[ "${1}" == '-run' ]] ; then
        dmenu_run "${DM_SETTINGS[@]}"
    else
        dmenu "${DM_SETTINGS[@]}" < "${1:-/dev/stdin}"
    fi
}

main "${@}"
