#!/bin/bash

#DEFINES CHECKING
isint()     { if [[ "${1}" =~ ^([\-]?[1-9][0-9]?+|0)$ ]] ; then echo "yes"; else echo "no"; fi }
isposint()  { if [[ "${1}" =~      ^([1-9][0-9]?+|0)$ ]] ; then echo "yes"; else echo "no"; fi }

IFS=$'\n'
DATA_FILE="$HOME/bin/nitroDATA.txt"
WF_DATA="$(   sed -n 1p "${DATA_FILE}")"
if   [[ "${1}" = "UP" ]] ; then WF_DATA="$(( "${WF_DATA}" + "1" ))"; elif [[ "${1}" = "DOWN" ]] ; then WF_DATA="$(( "${WF_DATA}" + "-1" ))"; fi
LF_DIR="$(    sed -n 2p "${DATA_FILE}")"
PIC_DIR="$(   sed -n 3p "${DATA_FILE}")"

if [[ -d "${LF_DIR}" ]] ; then cd "${LF_DIR}";  else echo "2nd Line (LF_DIR) Not Dir"; exit 1; fi

#------------------------------------------------------------------------START--------------------------------------------------------------------#

DIRS_L=($(echo "$(ls -Ltd -1 *'/')"))
DLEN="${#DIRS_L[@]}"

if [[ ! -d "${PIC_DIR}" ]] ; then echo "3nd line DATA FILE NOT DIR"; DPOS="1"
else DPOS="$( echo "${DIRS_L[*]}" | grep -xnF "${PIC_DIR}" | grep -Pio '^[1-9]+[0-9]?+' )"
	 DPOS=$(( "${DPOS}" - "1" )); fi


if   [[ "$?" != "0"               ]] ; then echo "ISSUE WITH PIC_DIR"; exit 1; fi
if   [[ "${1}" =  "LEFT"          ]] ; then DPOS="$(( "${DPOS}" - "1" ))" ; elif [[ "${1}" = "RIGHT" ]] ; then DPOS="$(( "${DPOS}" + "1" ))"; fi
if   [[ "${DPOS}" -lt "0"         ]] ; then DPOS="${DLEN}"; elif [[  "${DPOS}" -gt "${DLEN}" ]] ; then DPOS="0" ; fi
if   [[ ! -d "${DIRS_L[${DPOS}]}" ]] ; then echo "line 43 not dir"; exit 1; fi


PIC_DIR="${DIRS_L[${DPOS}]}"
sed -i '3s#.*#'"${PIC_DIR}"'#' "${DATA_FILE}"

PICS_L=($(echo "$(ls -Lt -1 "${PIC_DIR}"*.png "${PIC_DIR}"*.jpg 2>/dev/null)"))
PLEN="${#PICS_L[@]}"

WF_DATA=$(( "${WF_DATA}" % "${PLEN}" ))

# -------------------------- PART 2
nitrogen --head=0 --save --set-zoom-fill "${PICS_L[${WF_DATA}]}"
nitrogen --head=1 --save --set-zoom-fill "${PICS_L[${WF_DATA}]}"

sed -i '1s#.*#'"${WF_DATA}"'#' "${DATA_FILE}"
sed -i '2s#.*#'"${LF_DIR}"'#'  "${DATA_FILE}"
