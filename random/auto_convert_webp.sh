#!/bin/bash

cd "${1:-/home/$USER/Pictures}"
IFS=$'\n'

for oldfile in $(find . -name "*.webp") ; do

	newfile="${oldfile::-6}.png"

	echo "_"
	echo "IN:  ${oldfile}"; echo "OUT: ${newfile}"

	dwebp "${oldfile}" -o "${newfile}"

	if [[ "$?" -ne "0" ]] || ! [[ -f "${newfile}" ]] ; then 
		"!!!!-ERROR:-FILE-NOT-CREATED"
		continue
	fi

	echo ">>>>-SUCCESS:-Png-created-successfully" 
	echo "AUTO DELETING WEBP"

	rm "${oldfile}" ; if [[ -f "${oldfile}" ]] ; then  
		echo "!!!!-ERROR:-FILE-NOT-DELETED"
		continue
	fi

	echo ">>>>-:--${oldfile}--DELETED"   

done
