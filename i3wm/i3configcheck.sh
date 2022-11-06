#!/bin/bash


ASK() {
	timeout "${1}" i3-input -f 'xft:Hermit 15' -l 1 -P 'SUCCESS RELOAD RESTART i3wm? (y/n)'\
		| grep -Pi '(?<=^command = ).+$'
	return "$?"
}

TIMEOUT="3"

while [[ "${1}" =~ ^- ]] ; do
	if   [[ "${1}" =~ ^--NOASK$  ]] ; then o_NOASK="Y"
	elif [[ "${1}" =~ ^--[0-9]+$ ]] ; then TIMEOUT="${1: 2}"; fi
	shift 1
done


OUT="$(i3 -C "${1:-"/home/maceurt/.i3/config"}")"

if 	 [[ "$?" -ne 0 ]] || [[ -n "${OUT}" ]] ; then
	i3-input -f 'xft:Hermit 15' -l 1 -P '!![Error in your config file]!!'
	exit 0
elif [[ "${o_NOASK:-"$(ASK ${TIMEOUT})"}" =~ ^[^yY]*$ ]] ; then
	timeout "${TIMEOUT}"\
		i3-input -l 1 -f 'xft:Hermit 15' -P 'NOT Reloading/Restarting'; exit 0
fi

i3-msg 	"reload; restart"

if [[ "${TIMEOUT}" -gt "0" ]] ; then
	timeout "${TIMEOUT}"\
		i3-input -l 1 -f 'xft:Hermit 15' -P 'Reloaded & Restarted'
fi
