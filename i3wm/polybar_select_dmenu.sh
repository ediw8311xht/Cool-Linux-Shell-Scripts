#!/bin/bash

####################
( #-START-SUBSHELL-#
####################

function main() {
    tmpfile="$(mktemp /tmp/mdmenu.XXXXXX)"
    trap "trash-put '${tmpfile}'" EXIT
    cd "$HOME/.config/polybar/configs/" || return "$?"
    find ./* -type f >> "${tmpfile}"
    choice="$(dmenu -b -nb "#000000" -i -l 10 -fn "Office Code Pro:pixelsize=20:antialias=true:autohint=true" -p "OPEN:" < "${tmpfile}")" || exit 1

    echo "${choice}"

    "${HOME}/bin/polybar_manipulate.sh" "CONFIG" "${choice}"
}

main

####################
) #---END-SUBSHELL-#
####################
