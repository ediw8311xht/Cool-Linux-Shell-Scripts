#!/bin/bash

OUT="$(i3 -C "${1:-"/home/maceurt/.i3/config"}")"
if [[ "$?" -ne 0 ]] || [[ -n "${OUT}" ]] ; then
	timeout 5 i3-input -f 'xft:Hermit 15' -l 1 -P 'Error in your config file'
else
	A="$(timeout 5 i3-input -f 'xft:Hermit 15' -l 1 -P 'Success: Reload & Restart i3wm? (y/n)' |\
		grep -Pi '(?<=^command = ).+$')"
	if [[ "${A}" =~ (y|Y) ]] ; then
		i3-msg "reload; restart"
		timeout 5 i3-input -l 1 -f 'xft:Hermit 15' -P "Reloaded & Restarted"
	else
		timeout 5 i3-input -l 1 -f 'xft:Hermit 15' -P "Not Reloading"
	fi
fi
