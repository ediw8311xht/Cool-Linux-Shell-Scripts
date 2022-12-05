#!/bin/bash

#-----------------FUNCTIONS----------------------------------------------#
conimage()  { ls -Lt -1 "${1}" 2>/dev/null | grep -P --silent '\.(png|jpg|jpeg)$' 2>/dev/null
			  if [[ "$?" -eq "0" ]] ; then echo "yes"; else echo "no"; fi					   ; }
addmod()  	{ echo "$(( "$(( "${1}" + "${2}" ))" % "${3}" ))"								   ; }

#-----------------ASSIGNING-AND-VALIDATING-------------------------------#
IFS=$'\n'
DATA_FILE="$HOME/bin/Data/nitroDATA.txt"; 				if [[ "$?" -ne "0"      ]] || [[ ! -f "${DATA_FILE}" ]] ; then echo "DATA FILE NOT FOUND"	; exit 1; fi
LF_DIR="$( sed -n 1p "${DATA_FILE}")"; cd "${LF_DIR}";  if [[ "$?" -ne "0"      ]] 								; then echo        "LF_DIR ISSUE" 	; exit 1; fi

DIRS_L=($( echo "$( ls -Lvd -1 *'/' 2>/dev/null )" ));  if [[ "$?" -ne "0"      ]] || [[ -z "${DIRS_L}" ]] 		; then echo        "DIRS_L ISSUE"	; exit 1; fi
DLEN="${#DIRS_L[@]}"; 									if [[ "${DLEN}" -le "0" ]] 								; then echo          "DLEN ISSUE"	; exit 1; fi

if [[ -n "${Z_HEAD}" ]] ; then
	echo "YOOO YOOOOOO"
	PIC_DIR="$(grep -nPio '^\-\-PIC_DIR\-${Z_HEAD}' "${DATA_FILE}")"
	PIC_POS="$(grep -nPio '^\-\-PIC_POS\-${Z_HEAD}' "${DATA_FILE}")"
fi
if [[ -z "${PIC_DIR}" ]] || [[ -z "${PIC_POS}" ]] ; then
	PIC_DIR="$(sed -n 2p "${DATA_FILE}")";				    if [[ ! -d "${PIC_DIR}" ]] ; then echo '"${PIC_DIR}" Not Dir'; PIC_DIR="${DIRS_L[0]}"				; fi
	PIC_POS="$(sed -n 3p "${DATA_FILE}")"; 					if [[ ! "${PIC_POS}" =~ ^(0|[-]?[1-9][0-9]?+)$ ]] ; then PIC_POS="0"; echo '"${PIC_POS}" not a num' ; fi
fi

DPOS="$( echo "${DIRS_L[*]}" | grep -xnF "${PIC_DIR}" | grep -Pio '^[1-9]+[0-9]?+' )"; DPOS="$(( "${DPOS}" - "1" ))"
SHOW_TYPE="auto"

while [[ "${1}" =~ ^-- ]] ; do
	if   [[ "${1}"  =~ ^--head-[0-9]+$  ]] ; then Z_HEAD="$(grep -Pio '[0-9]+' <<< "${1}")"
	elif [[ "${1}"  =  '--zoom' 	    ]] ; then SHOW_TYPE="zoom"
	elif [[ "${1}"  =  '--auto'         ]] ; then SHOW_TYPE="auto"
	elif [[ "${1}"  =  '--tiled'        ]] ; then SHOW_TYPE="tiled"
	elif [[ "${1}"  =  '--centered'     ]] ; then SHOW_TYPE="centered"
	elif [[ "${1}"  =  '--zoom-fill'    ]] ; then SHOW_TYPE="zoom-fill"; fi
	shift
done

if   [[ "${1}"  = "UP"    ]] ; then PIC_POS="$(( "${PIC_POS}" + "1" ))"
elif [[ "${1}"  = "DOWN"  ]] ; then PIC_POS="$(( "${PIC_POS}" + "-1" ))"
elif [[ "${1}"  = "LEFT"  ]] ; then PIC_POS="0" ;  ADD_BY="-1" ; DPOS="$( addmod "${DPOS}" "${ADD_BY}" "${DLEN}" )"
elif [[ "${1}"  = "RIGHT" ]] ; then PIC_POS="0" ;  ADD_BY="1"  ; DPOS="$( addmod "${DPOS}" "${ADD_BY}" "${DLEN}" )"
else										       ADD_BY="0"  ; fi

lim="${DLEN}"
while [[ ! "$(conimage "${DIRS_L[${DPOS}]}")" = "yes"  ]] ; do
	PIC_POS="0"; DPOS="$( addmod "${DPOS}" "${ADD_BY}" "${DLEN}" )"
	if [[ "lim=$(($lim-1))" -le "0" ]] ; then 
		echo "COULD NOT FIND ANY DIRECTORY WITH IMAGE FILES"; exit 1; fi
done

PICS_L=($(echo "$(ls -Lt -1 "${DIRS_L[${DPOS}]}"*.png "${DIRS_L[${DPOS}]}"*.jpeg "${DIRS_L[${DPOS}]}"*.jpg 2>/dev/null)"))
PIC_DIR="${DIRS_L[${DPOS}]}"
PIC_POS="$(( "${PIC_POS}" % "${#PICS_L[@]}" ))"

#-----------------SET-WALLPAPER------------------------------------------#
#-----------------FIX--TO--KAJFKAjkfajkfj
#if [[ -n "${Z_HEAD}" ]] ; then
#	echo "HI"
#	nitrogen --head="${Z_HEAD}" --save --set-${SHOW_TYPE} "${PICS_L[${PIC_POS}]}"
#	#-----------------UPDATE-DATA-FILE---------------------------------------#
#	sed -i '1s#.*#'"${LF_DIR}"'#'  "${DATA_FILE}"
#	sed -i '2s#.*#'"${PIC_DIR}"'#' "${DATA_FILE}"
#	sed -i '3s#.*#'"${PIC_POS}"'#' "${DATA_FILE}"
#else 
#	echo "BYE"
#	nitrogen --head=0 --save --set-${SHOW_TYPE} "${PICS_L[${PIC_POS}]}"
#	nitrogen --head=1 --save --set-${SHOW_TYPE} "${PICS_L[${PIC_POS}]}"
#	#-----------------UPDATE-DATA-FILE---------------------------------------#
#	sed -i '1s#.*#'"${LF_DIR}"'#'  "${DATA_FILE}"
#	sed -i '2s#.*#'"${PIC_DIR}"'#' "${DATA_FILE}"
#	sed -i '3s#.*#'"${PIC_POS}"'#' "${DATA_FILE}"
#fi
nitrogen --head=0 --save --set-${SHOW_TYPE} "${PICS_L[${PIC_POS}]}"
nitrogen --head=1 --save --set-${SHOW_TYPE} "${PICS_L[${PIC_POS}]}"
#-----------------UPDATE-DATA-FILE---------------------------------------#
sed -i '1s#.*#'"${LF_DIR}"'#'  "${DATA_FILE}"
sed -i '2s#.*#'"${PIC_DIR}"'#' "${DATA_FILE}"
sed -i '3s#.*#'"${PIC_POS}"'#' "${DATA_FILE}"

c_send() {
	TIME="10000" ## -- Milliseconds to wait -- (1/1000) of Second -- ##
	if [[ "${3}" = "E" ]] ; then MBG="${5:-"#000000"}"; MFG="${6-"#FF0000"}"; MFR="${7-"#FF0000"}"; 
	else 					     MBG="${5:-"#000000"}"; MFG="${6-"#00FF00"}"; MFR="${7-"#000000"}"; fi

	notify-send -h string:bgcolor:"${MBG}"\
				-h string:fgcolor:"${MFG}"\
				-h string:frcolor:"${MFR}"\
				-t "${TIME}"\
				"${1}" "${2}" 
}

dunstctl close-all
PIC_NAME_EE="${PICS_L[${PIC_POS}]}"
c_send "${SHOW_TYPE} - ${PIC_DIR}" "${PIC_NAME_EE##*/}"

