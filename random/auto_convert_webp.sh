#!/bin/bash

if [[ "$#" -gt "0" ]] && [[ -d "${1}" ]] ; then 
	EXPATH="$1"
else
	EXPATH="$HOME/Pictures/"
fi

cd "${EXPATH}"

for s in $(find . -maxdepth 1 -name "*.webp") ; do
    j=$(basename -s .webp "${s}")
	dwebp "${j}.webp" -o "${j}.png"
	echo $d

	#check to see if file was created successfully
	if [[ "$?" -eq 0 ]] && [[ -f "${j}.png" ]] && [[ -f "${j}.webp" ]] ; then

		echo "--------Png created successfully" 

		if [[ "$#" -gt "1" ]] && [[ "$2" =~ ^[y|Y]$ ]] ; then
			echo "AUTO DELETING WEBP"
			rm "${j}.webp"
		elif [[ "$#" -lt "2" ]] || [[ ! "$2" =~ ^[n|N]$ ]] ; then
			a=""; echo "Do you want to delete the webp? > "; read a
			if [[ "$a" =~ [y|Y]([e|E][s|S])?$ ]] ; then	rm "${j}.webp"; fi
		fi

		echo ""

		if [[ -f "${j}.webp" ]] ; then
			echo "-------FILE NOT DELETED"
		else
			echo "-------FILE DELETED"
		fi
	fi
done
