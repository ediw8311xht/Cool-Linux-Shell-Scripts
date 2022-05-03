#!/bin/bash

#-----------------FUNCTIONS----------------------------------------------#
conimage()  { ls -Lt -1 "${1}" 2>/dev/null | grep -P --silent '\.(png|jpg)$' 2>/dev/null
			  if [[ "$?" -eq "0" ]] ; then echo "yes"; else echo "no"; fi					   ; }
addmod()  	{ echo "$(( "$(( "${1}" + "${2}" ))" % "${3}" ))"								   ; }

#-----------------ASSIGNING-AND-VALIDATING-------------------------------#
IFS=$'\n'
DATA_FILE="$HOME/bin/nitroDATA.txt"; 					if [[ "$?" -ne "0"      ]] || [[ ! -f "${DATA_FILE}" ]] ; then echo "DATA FILE NOT FOUND"	; exit 1; fi
LF_DIR="$( sed -n 1p "${DATA_FILE}")"; cd "${LF_DIR}";  if [[ "$?" -ne "0"      ]] 								; then echo        "LF_DIR ISSUE" 	; exit 1; fi
DIRS_L=($( echo "$( ls -Ltd -1 *'/' 2>/dev/null )" ));  if [[ "$?" -ne "0"      ]] || [[ -z "${DIRS_L}" ]] 		; then echo        "DIRS_L ISSUE"	; exit 1; fi
DLEN="${#DIRS_L[@]}"; 									if [[ "${DLEN}" -le "0" ]] 								; then echo          "DLEN ISSUE"	; exit 1; fi
PIC_DIR="$(sed -n 2p "${DATA_FILE}")";				    if [[ ! -d "${PIC_DIR}" ]] ; then echo '"${PIC_DIR}" Not Dir'; PIC_DIR="${DIRS_L[0]}"				; fi
PIC_POS="$(sed -n 3p "${DATA_FILE}")"; 					if [[ ! "${PIC_POS}" =~ ^(0|[-]?[1-9][0-9]?+)$ ]] ; then PIC_POS="0"; echo '"${PIC_POS}" not a num' ; fi
DPOS="$( echo "${DIRS_L[*]}" | grep -xnF "${PIC_DIR}" | grep -Pio '^[1-9]+[0-9]?+' )"; DPOS="$(( "${DPOS}" - "1" ))"

if   [[ "${1}"  =    "UP" ]] ; then PIC_POS="$(( "${PIC_POS}" + "1" ))"
elif [[ "${1}"  =  "DOWN" ]] ; then PIC_POS="$(( "${PIC_POS}" + "-1" ))"
elif [[ "${1}"  =  "LEFT" ]] ; then PIC_POS="0" ; ADD_BY="-1"  ; DPOS="$( addmod "${DPOS}" "${ADD_BY}" "${DLEN}" )"
elif [[ "${1}"  = "RIGHT" ]] ; then PIC_POS="0" ;  ADD_BY="1"  ; DPOS="$( addmod "${DPOS}" "${ADD_BY}" "${DLEN}" )"
else										       ADD_BY="1"  ; fi

lim="${DLEN}"
while [[ ! "$(conimage "${DIRS_L[${DPOS}]}")" = "yes"  ]] ; do
	PIC_POS="0"; DPOS="$( addmod "${DPOS}" "${ADD_BY}" "${DLEN}" )"
	if [[ "lim=$(($lim-1))" -le "0" ]] ; then 
		echo "COULD NOT FIND ANY DIRECTORY WITH IMAGE FILES"; exit 1; fi
done

PICS_L=($(echo "$(ls -Lt -1 "${DIRS_L[${DPOS}]}"*.png "${DIRS_L[${DPOS}]}"*.jpg 2>/dev/null)"))
PIC_DIR="${DIRS_L[${DPOS}]}"
PIC_POS="$(( "${PIC_POS}" % "${#PICS_L[@]}" ))"
#-----------------SET-WALLPAPER------------------------------------------#
nitrogen --head=0 --save --set-zoom-fill "${PICS_L[${PIC_POS}]}"
nitrogen --head=1 --save --set-zoom-fill "${PICS_L[${PIC_POS}]}"
#-----------------UPDATE-DATA-FILE---------------------------------------#
sed -i '1s#.*#'"${LF_DIR}"'#'  "${DATA_FILE}"
sed -i '2s#.*#'"${PIC_DIR}"'#' "${DATA_FILE}"
sed -i '3s#.*#'"${PIC_POS}"'#' "${DATA_FILE}"

