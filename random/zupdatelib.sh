#!/bin/bash

## ARGUMENTS:
## WITHOUT OPTION IN LIST BELOW AS ($1) ARGUMENT, 
## ARGUMENTS WILL BE TAKEN AS LIST "TO_GET"
#
# OPTIONS 
# -d: NEXT ARGUMENT  ($2) TO BE TAKEN AS DIRECTORY A ("DIR_A")
# -s: NEXT ARGUMENT  ($2) TO BE TAKEN AS LIST "TO_GET"
# -l: NEXT ARGUMENTS ($@) TO BE TAKEN AS LIST "TO_GET"

DIR_A="/mnt/od/UPLOADED"
DIR_B="/mnt/ad/LNB/BACKUP"
DATA_FILE="/mnt/ad/LNB/DataFiles/library_data.txt"
#GSCRIPT="/mnt/ad/LNB/not_in_lib.sh"

xr() { tput setaf   1; }; xg() { tput setaf   2; }; xy() { tput setaf  3; }; xb() { tput setaf 45; }; xw() { tput setaf 7; }
xp() { tput setaf 200; }; xo() { tput setaf 208; }; xl() { tput setaf 13; }

myread() 	{ 	J=""; read -p "${1}" J; echo "${J}"; return 0; }
myrename() 	{ 	perl -pe 's/[\[\]\,\ ]/_/g' <<< "${1}";  return 0; }

if   [[ "${1}" =~ -(y|Y|yes|Yes) ]] ; then SR="Y"; shift 1
elif   [[ "${1}" =~ -(n|N|no|No) ]] ; then SR="N"; shift 1; fi


if     [[ -z "${@}" ]] ; 	then IFS=$'\n'; C="$(ls -1 "${DIR_A}")" 
elif [[ "${1}" = '-d' ]] ; 	then

	if [[ ! -d "${2}" ]] ; 	then xr; echo "INVALID DIRECTORY"; exit 1
	else 						 IFS=$'\n'; C="$(ls -1 "${DIR_A}")"; 	DIR_A="${2}"; fi

elif [[ "${1}" = '-s' ]] ; 	then to_get=($(echo "${2}")); DIR_A=""
elif [[ "${1}" = '-l' ]] ; 	then to_get=(${@}); DIR_A=""
else 							 xr; echo "INVALID ARGUMENTS"; exit 1; fi

# CHECK DIRECTORY B AND DATA_FILE; THEIR SHOULD ALWAYS BE A DATA_FILE FOR A DIRECTORY & VICE VERSA
if 	     [[ ! -d "${DIR_B}" ]] ; then xr; echo "DIRECTORY B (DIR_B) DOES NOT EXIST"; exit 1
elif [[ ! -f "${DATA_FILE}" ]] ; then xr; echo "DATA FILE DOESN'T EXIST"; exit 1; fi

if [[ -z "${@}" ]] || [[ "${1}" = '-d' ]] ; then
	# BY DEFAULT IGNORING .TORRENT FILES
	mytemp="$(mktemp)"
	echo "$(echo "${C}" | grep -Pio '^.+(?<!\.torrent)$')" > "${mytemp}"

	# ALWAYS MUST SORT BEFORE USING "COMM"
	sort "${mytemp}" -o "${mytemp}"; sort "${DATA_FILE}" -o "${DATA_FILE}"
	to_get=($(comm -23 "${mytemp}" "${DATA_FILE}"))

	xy; Z=${IFS}; IFS=$'\n'; echo $'\n'"FILES TO COPY TO DIR:"; echo "${to_get[*]}"; IFS=${Z}

	xb; echo ""; if [[ ! "${SR:-$(myread "Continue? (Y|n) > ")}" =~ ^(|Y|y|Yes|yes)$ ]] ; then 
		echo "EXITING"; exit 0
	fi

fi


COUNT=0
for key in "${to_get[@]}" ; do 

	#DEST="${DIR_B}/${key}"
	RENAME="${DIR_B}/$( myrename "${key}.tar.gz" )"


	echo "${RENAME}"

	if [[ ! -f "${DIR_A}/${key}" ]] && [[ ! -d "${DIR_A}/${key}" ]] ; then
		xr; echo "FILE ${key} DOES NOT EXIST IN DIR: ${DIR_A}"
		continue
	elif [[ -f "${DEST}" ]] || [[ -d "${DEST}" ]] ; then
		xr; echo ""; echo "FILE ${key} ALREADY EXISTS IN DESTINATION"
		xb; if [[ ! "${SR:-$(myread "ADD ${key} TO DATA FILE (y|N)?")}" =~ ^(Y|y|Yes|yes)$ ]] ; then 
			continue
		fi
	else  
		tar -czvf "${DIR_A}/${RENAME}" "${DIR_B}/${key}"
		if [[ ! "$?" -eq "0" ]] ; then xr; echo "FILE DID NOT COPY CORRECTLY"; continue
		else						   COUNT=$(( "${COUNT}" + "1" )); xg; echo "COUNT: ${COUNT}"; fi
	fi

	if [[ -f "${DEST}" ]] || [[ -d "${DEST}" ]] ; then
		# ADDING TO DATA_FILE
		xp; echo ""; echo "----> ADDING ${key} TO DATA FILE"; sleep 0.1
		xg; echo "${key}" >> "${DATA_FILE}"; sleep 0.1
	else
		echo "SOMETHING WENT WRONG LINE 79"
	fi
	echo ""; sleep 0.1
done

