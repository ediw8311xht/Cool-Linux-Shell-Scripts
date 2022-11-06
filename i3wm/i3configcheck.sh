#!/bin/bash

function ASK() {
    timeout "${1}" i3-input -f "${FG_FONT}" -l 1 -P 'SUCCESS RELOAD RESTART i3wm? (y/n)'\
        | grep -Pi '(?<=^command = ).+$'
    return "$?"
}

function HANDLE_OPTIONS() {
    while [[ "${1}" =~ ^- ]] ; do
        if   [[ "${1}" =~ ^--NOASK$  ]] ; then o_NOASK="Y"
        elif [[ "${1}" =~ ^--[0-9]+$ ]] ; then TIMEOUT="${1: 2}"
        elif [[ "${1}" =~ ^--[cC]$   ]] ; then 
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

function LOGIC() {
    OUT="$(i3 -C "${CONFIG_ELSE}")"
    if 	 [[ "$?" -ne 0 ]] || [[ -n "${OUT}" ]] ; then
    	i3-input -f "${FG_FONT}" -l 1 -P '!![Error in your config file]!!'
    	exit 0
    elif [[ "${o_NOASK:-"$(ASK "${TIMEOUT}")"}" =~ ^[^yY]*$ ]] ; then
    	timeout "${TIMEOUT}"\
       	i3-input -l 1 -f "${FG_FONT}" -P 'NOT Reloading/Restarting'; exit 0
    fi
    
    i3-msg 	"reload; restart"
    
    if [[ "${TIMEOUT}" -gt "0" ]] ; then
        timeout "${TIMEOUT}"\
      	i3-input -l 1 -f "${FG_FONT}" -P 'Reloaded & Restarted'
    fi
}

#-----------VARS
TIMEOUT="3"
CONFIG_ELSE="$(if ! [[ -f "$HOME/.i3/config" ]] ; then echo "$HOME/.config/i3/config"; else echo "$HOME/.i3/config"; fi)"
FG_FONT="${2:-"xft:monospace 15"}"
#-----------VARS

HANDLE_OPTIONS "$@"
LOGIC

