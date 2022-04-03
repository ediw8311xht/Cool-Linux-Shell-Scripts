#!/bin/bash

# $1	  $2			$3			    $4			$5
# DIR_IN, IMAGE_REGEX,	SKIP_ROTATION,  COMPLETED	$COMPLETED_PDFS

xr() { tput setaf   1; }; xg() { tput setaf   2; }; xy() { tput setaf  3; }; xb() { tput setaf 45; }; xw() { tput setaf 7; }
xp() { tput setaf 200; }; xo() { tput setaf 208; }; xl() { tput setaf 13; }

IFS=$'\n'; DIR_T="${1:-"$HOME/SCAN/UNCOMPLETED"}"

cd "${DIR_T}"

if [[ ! "$?" -eq "0" ]] ; then
	xr; sleep 0.8; echo "EXITING, PROBLEM CD'ing INTO ${DIR_T}."; exit 1
fi

DIRECTORIES=($(ls -1d *"/"))
REGEX_T="${2:-.*.png}"
COMPLETED="${4:-"$HOME/SCAN/COMPLETED"}"
COMPLETED_PDFS="${5:-"$HOME/SCAN/COMPLETED_PDFS"}"

for DIR in ${DIRECTORIES[@]} ; do

	FILES=($(ls -1 "${DIR}" | grep -Pi "${REGEX_T}" | sed "s|^|${DIR}|")) 
	
	if [[ ! "$?" -eq "0" ]] ; then xr; sleep 0.8; echo "ISSUE LS'ing ${DIR}."; continue; fi

	if [[ ! "${3}" = "_" ]] ; then
		xb; echo "NOW ROTATING FILES."
		for FILE in ${FILES[@]} ; do
			xy; echo "${FILE}"
			xg; convert "${FILE}" -rotate 180 "${FILE}"

			if [[ "$?" -eq "0" ]] ; then xg; echo "SUCCESS, ROTATING FILE ${FILE}."; echo ""
			else					 xr; echo "FAILED,  ROTATING FILE ${FILE}."; echo ""; fi
		done
	else 
		xb; echo "SKIPPED ROTATING FILES."; echo ""
	fi

	A="$(sed 's^[\ \*\-\,\=\+\:\|\$\?\.\"]^_^g' <<< "${DIR}" | sed 's|[\^\/]||g').pdf"
	i=0; LIMIT=1000000
	echo "${A}"
	while [[ -f "${i}-_${A}" ]] ; do
		i=$(( "${i}" + 1 ))
		if [[ "${i}" -gt "${LIMIT}" ]] ; then echo "LIMIT REACHED LINE 34, FILE LOOP"; exit 1; fi
	done
	if [[ "${i}" -gt 0 ]] ; then A="${i}-_${A}"; fi	

	sleep 0.8; echo ""; echo "${FILES[*]}"; sleep 0.5; 

	IFS=$'\n'; img2pdf ${FILES[@]} -o "${A}"
	if [[ -f "${A}" ]] && [[ "$?" -eq "0" ]] ; then 
		xg; echo "SUCCESS, OUTPUT: ${A}"
		cp "${A}" "${DIR}/${A}"
	else 										    
		xr; echo "FAILURE"
	fi

	echo ""; sleep 0.8

	echo "${COMPLETED}"; echo "${COMPLETED_PDFS}"
	xb; INP=""; read -p "MOVE FILES TO COMPLETED (y|N) ?" INP; sleep 0.5; echo ""

	if [[ "${INP}" =~ (y|Y|yes|Yes) ]] ; then
		mv "${DIR}" "${COMPLETED}"
		mv "${A}" "${COMPLETED_PDFS}"
	fi
done
