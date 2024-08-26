#!/bin/bash

####################
( #-START-SUBSHELL-#
####################

#---------------------------------------------------------#
#------------------------------VARIABLES------------------#
#---------------------------------------------------------#
TIMEOUT="3"
CONFIG_ELSE="${HOME}/.i3/config"
CACHE_ERROR_FILE="${HOME}/.cache/i3_error.txt"
[[ -f "${HOME}/.i3/config" ]] || CONFIG_ELSE="${HOME}/.config/i3/config"
FG_FONT='xft:monospace 10'

#---------------------------------------------------------#
#------------------------------FUNCTIONS------------------#
#---------------------------------------------------------#
ASK() {
    timeout "${1}" i3-input -f "${FG_FONT}" -l 1 -P 'SUCCESS RELOAD RESTART i3wm? (y/n)'\
        | grep -Pi '(?<=^command = ).+$'
    return "$?"
}

HANDLE_OPTIONS() {
    while [[ "${1}" =~ ^- ]] ; do
        if   [[ "${1,,}" =~ ^--noask$  ]] ; then o_NOASK="Y"
        elif [[ "${1,,}" =~ ^--[0-9]+$ ]] ; then TIMEOUT="${1: 2}"
        elif [[ "${1,,}" =~ ^--c$      ]] ; then
        #---------------CONFIG
        if ! [[ -f "${2}"        ]] ; then
            echo "VALID CONFIG FILE NOT PROVIDED WITH --[Cc]"; exit 1
            else
                if   [[ "${1}" =~ --c ]] ; then
                    CONFIG_ELSE="${2}"
                elif [[ "${1}" =~ --C ]] ; then
                    mv "${CONFIG_ELSE}" "$(date +'%Y_%m_%d_')${CONFIG_ELSE}"\
                    && link "${2}" "${CONFIG_ELSE}"
                fi
                    shift 1
            fi
        fi
        shift 1
    done
}

LOGIC() {
    if 	! i3 -C "${CONFIG_ELSE}"  &> "${CACHE_ERROR_FILE}" ; then
    	i3-input -f "${FG_FONT}" -l 1 -P '!![Error in your config file]!!'
    	exit 1
    elif [[ "${o_NOASK:-"$(ASK "${TIMEOUT}")"}" =~ ^[^yY]*$ ]] ; then
    	timeout "${TIMEOUT}" \
       	i3-input -l 1 -f "${FG_FONT}" -P 'NOT Reloading/Restarting'; exit 0
    fi

    i3-msg 	"reload; restart"

    if [[ "${TIMEOUT}" -gt "0" ]] ; then
        timeout "${TIMEOUT}"\
      	i3-input -l 1 -f "${FG_FONT}" -P 'Reloaded & Restarted'
    fi
}

#---------------------------------------------------------#
#------------------------------MAIN-----------------------#
#---------------------------------------------------------#
main() {
    #### FG_FONT='xft:monospace 15'
    HANDLE_OPTIONS "$@"
    LOGIC
}

main "${@}"

####################
) #---END-SUBSHELL-#
####################

