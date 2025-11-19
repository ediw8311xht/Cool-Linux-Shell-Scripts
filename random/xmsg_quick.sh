#!/bin/bash


####################
( #-START-SUBSHELL-#
####################
OPTIONS=()
MESSAGE=""

handle_args() {

    while [[ "${#}" -gt 0 ]] ; do
        if   [[ "${1}"     =~ ^(--)$       ]] ; then MESSAGE="${*:2}" ; return 0
        elif [[ "${1}"     =~ ^[^-].*$     ]] ; then MESSAGE="${*}"   ; return 0
        elif [[ "${*:1:2}" =~ ^-b\ .+$     ]] ; then OPTIONS+=( -button  "${2}" ) ; shift 1
        elif [[ "${*:1:2}" =~ ^-t\ [0-9]+$ ]] ; then OPTIONS+=( -timeout "${2}" ) ; shift 1
        else echo "Invalid Option: '${1}'"; exit 1; fi
        shift 1
    done
}

main() {
    handle_args "${@}"
    # echo "${OPTIONS[@]}"
    xmessage -geometry +80+10 "${OPTIONS[@]}" -file - <<< "${MESSAGE[@]}"
}

main "${@}"

####################
) #---END-SUBSHELL-#
####################

# Xmessage*message.Scroll:    Never
# Xmessage*message.Border:    0
# Xmessage*background:        #008fF8
# Xmessage*foreground:        #000000
# Xmessage*geometry:          +5+5
# Xmessage*.*bw:              20
# Xmessage*font:              -bitstream-tahoma-medium-r-normal--30-15-0-0-p-0-ascii-0
# Xmessage*Buttons:
