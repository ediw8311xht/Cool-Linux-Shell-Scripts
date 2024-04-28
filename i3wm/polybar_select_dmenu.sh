#!/bin/bash

####################
( #-START-SUBSHELL-#
####################

function main() {
    local choice=""
    cd "$HOME/.config/polybar/configs/" || return "$?"
    choice="$(find . -type f -printf "%f\n" | "$HOME/bin/my_dmenu.sh")"

    echo "${choice}"

    "${HOME}/bin/polybar_manipulate.sh" "CONFIG" "${choice}"
}

main

####################
) #---END-SUBSHELL-#
####################
