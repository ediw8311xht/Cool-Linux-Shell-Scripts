#!/bin/bash

####################
( #-START-SUBSHELL-#
####################
DM_SETTINGS=(
    -i
    -l  '19'
    -b
    -x  '20'
    -y  '20'
    -w  '500'
    -sb '#002255'
    -sf '#FFFFFF'
    -nf '#999999'
    -nb '#000000'
    -fn 'Hermit:style=Regular:pixelsize=12:antialias=true:autohint=true'
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

####################
) #---END-SUBSHELL-#
####################
