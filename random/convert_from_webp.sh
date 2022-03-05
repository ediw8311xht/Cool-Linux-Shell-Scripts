#!/bin/bash

if [[ "$#" == "0" ]] && [[ -d "$1" ]] ; then 
	EXPATH="$1"
else
	EXPATH="$HOME/Pictures/"
fi

cd "${EXPATH}"

for s in $(find . -name "*.webp") ; do
    j=$(basename -s .webp "${s}")
	dwebp "${j}.webp" -o "${j}.png"
	if [[ "$?" -eq 0 ]] && [[ -f "${j}.png" ]] && [[ -f "${j}.webp" ]] ; then
		a=""; echo "png created successfully do you want to delete the webp?"; read a
		if [[ "$a" = "Y" ]] || [[ "$a" = "y" ]] || [[ "$a" = "yes" ]] || [[ "$a" = "Yes" ]]; then 
			rm -i "${j}.webp"
		fi
	fi
done
