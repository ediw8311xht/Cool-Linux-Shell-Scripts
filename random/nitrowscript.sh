#!/bin/bash

#-----------------FUNCTIONS----------------------------------------------#
conimage() { 
    if find "${1}" -type f -iregex '.*[.]\(png\|jpg\|jpeg\)'
    then return '0'; fi
    return '1'
}
addmod() {
    echo "$(( "$(( "${1}" + "${2}" ))" % "${3}" ))"
}
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
handle_args() {
    if [[ -z "${1}" ]] ; then return '0' ; fi

    case "${1}" in --zoom) SHOW_TYPE="zoom" 
           ;;      --auto) SHOW_TYPE="auto" 
           ;;     --tiled) SHOW_TYPE="tiled" 
           ;;  --centered) SHOW_TYPE="centered" 
           ;; --zoom-fill) SHOW_TYPE="zoom-fill" 
           ;;          UP) (( PIC_POS++ ))
           ;;        DOWN) (( --PIC_POS ))
           ;;        LEFT) PIC_POS="0" ;  ADD_BY="-1" ; DPOS="$( addmod "${DPOS}" "${ADD_BY}" "${DLEN}" )"
           ;;       RIGHT) PIC_POS="0" ;  ADD_BY="1"  ; DPOS="$( addmod "${DPOS}" "${ADD_BY}" "${DLEN}" )"
           ;;           *) return '1'
           ;; esac
    shift ;  handle_args "${@}"
}

#-----------------ASSIGNING-AND-VALIDATING-------------------------------#
IFS=$'\n'
if ! DATA_FILE="$HOME/bin/Data/nitroDATA.txt" ; then 
        return '1'
elif ! LF_DIR="$( sed -n 1p "${DATA_FILE}")" || ! cd "${LF_DIR}" ; then
    return '1'
elif ! DIRS_L=($( echo "$( find *'/' -type d 2>/dev/null )" )) ; then
    return 1
elif ! DLEN="${#DIRS_L[@]}" ; then
    return 1
fi

if   ! PIC_DIR="$(sed -n 2p "${DATA_FILE}")"  ||
  [[ ! -d "${PIC_DIR}" ]]
then 
    PIC_DIR="${DIRS_L[0]}"
fi

if   ! PIC_POS="$(sed -n 3p "${DATA_FILE}")"  ||
  [[ ! "${PIC_POS}" =~ ^(0|[-]?[1-9][0-9]?+)$ ]]
then 
    PIC_POS="0"
fi

DPOS="$( echo "${DIRS_L[*]}" | grep -xnF "${PIC_DIR}" | grep -Pio '^[1-9]+[0-9]?+' )"
((--DPOS))

handle_args "${@}"
#-----------------ASSIGNING-AND-VALIDATING-------------------------------#

lim="${DLEN}"
while ! conimage "${DIRS_L[${DPOS}]}" ; do
	PIC_POS="0"; DPOS="$( addmod "${DPOS}" "${ADD_BY}" "${DLEN}" )"
    if [[ $((--lim)) -le '0' ]] ; then 
		echo "COULD NOT FIND ANY DIRECTORY WITH IMAGE FILES"
        return 1
    fi
done

#PICS_L=($(echo "$(ls -Lt -1 "${DIRS_L[${DPOS}]}"*.png "${DIRS_L[${DPOS}]}"*.jpeg "${DIRS_L[${DPOS}]}"*.jpg 2>/dev/null)"))

PICS_L=($(find ${DIRS_L[${DPOS}]} -type f -iregex '.*[.]\(png\|jpg\|jpeg\)'))

PIC_DIR="${DIRS_L[${DPOS}]}"
PIC_POS="$(( "${PIC_POS}" % "${#PICS_L[@]}" ))"

#-----------------SET-WALLPAPER------------------------------------------#
nitrogen --head=0 --save --set-${SHOW_TYPE:-auto} "${PICS_L[${PIC_POS}]}"
nitrogen --head=1 --save --set-${SHOW_TYPE:-auto} "${PICS_L[${PIC_POS}]}"
#-----------------UPDATE-DATA-FILE---------------------------------------#
sed -i '1s#.*#'"${LF_DIR}"'#'  "${DATA_FILE}"
sed -i '2s#.*#'"${PIC_DIR}"'#' "${DATA_FILE}"
sed -i '3s#.*#'"${PIC_POS}"'#' "${DATA_FILE}"

dunstctl close-all

PIC_NAME_EE="${PICS_L[${PIC_POS}]}"

c_send "${SHOW_TYPE:-auto} - ${PIC_DIR}" "${PIC_NAME_EE##*/}"

