#!/bin/sh

tmpfile=$(mktemp /tmp/mdmenu.XXXXXX)
trap 'rm "$tmpfile"' 0 1 15
cd "$HOME/.config/polybar/configs/" || return "$?"
find * -type f >> "${tmpfile}"
choice="$(dmenu -b -nb "#000000" -i -l 10 -fn "Office Code Pro:pixelsize=20:antialias=true:autohint=true" -p "OPEN:" < "${tmpfile}")" || exit 1

echo "${choice}"

.  "$HOME/bin/polybar_manipulate.sh" "CONFIG" "${choice}"
