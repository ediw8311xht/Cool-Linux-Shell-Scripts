#!/bin/bash

###################
( #-BEGIN-SUBSHELL#
###################

IFS=$'\n'

#-----------------FUNCTIONS----------------------------------------------#
conimage() { 
    if find "${1}" -type f -iregex '.*[.]\(png\|jpg\|jpeg\)'
    then return '0'; fi
    exit 1
}
addmod() {
    echo "$(( "$(( "${1}" + "${2}" ))" % "${3}" ))"
}
c_send() {
	notify-send -h string:bgcolor:"#000000"\
				-h string:fgcolor:"#00FF00"\
				-h string:frcolor:"#00FF00"\
				-t "${3:-10000}" "${1}" "${2}" 
}
handle_args() {
    case "${1}" in --zoom) SHOW_TYPE="zoom" 
           ;;      --auto) SHOW_TYPE="auto" 
           ;;     --tiled) SHOW_TYPE="tiled" 
           ;;  --centered) SHOW_TYPE="centered" 
           ;; --zoom-fill) SHOW_TYPE="zoom-fill" 
           ;;          UP) (( PIC_POS++ ))
           ;;        DOWN) (( --PIC_POS ))
           ;;        LEFT) PIC_POS="0" ;  ADD_BY="-1" ; DPOS="$( addmod "${DPOS}" "${ADD_BY}" "${DLEN}" )"
           ;;       RIGHT) PIC_POS="0" ;  ADD_BY="1"  ; DPOS="$( addmod "${DPOS}" "${ADD_BY}" "${DLEN}" )"
           ;; esac
    shift && [[ "$#" -ge 1 ]] && handle_args "${@}"
}
#-----------------MAIN---------------------------------------------------#
if ! DATA_FILE="$HOME/bin/Data/nitroDATA.txt"    ||
   ! LF_DIR="$( sed -n 1p "${DATA_FILE}")"       || 
   ! cd "${LF_DIR}"                              ||
   ! DIRS_L=($( find *'/' -type d 2>/dev/null )) ||
   ! DLEN="${#DIRS_L[@]}"
then
    exit 1
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

lim="${DLEN}"
while ! conimage "${DIRS_L[${DPOS}]}" ; do
	PIC_POS="0" ; DPOS="$( addmod "${DPOS}" "${ADD_BY}" "${DLEN}" )"
    if [[ $((--lim)) -le '0' ]] ; then 
        exit 1
    fi
done

#-----------------UPDATED-VALUES-----------------------------------------#
PICS_L=($(find "${DIRS_L[${DPOS}]}" -type f -iregex '.*[.]\(png\|jpg\|jpeg\)'))
PIC_DIR="${DIRS_L[${DPOS}]}"
PIC_POS="$(( "${PIC_POS}" % "${#PICS_L[@]}" ))"
#-----------------SET-WALLPAPER------------------------------------------#
nitrogen --head=0 --save --set-${SHOW_TYPE:-auto} "${PICS_L[${PIC_POS}]}"
nitrogen --head=1 --save --set-${SHOW_TYPE:-auto} "${PICS_L[${PIC_POS}]}"
#-----------------UPDATE-DATA-FILE---------------------------------------#
sed -i '1s#.*#'"${LF_DIR}"'#'  "${DATA_FILE}"
sed -i '2s#.*#'"${PIC_DIR}"'#' "${DATA_FILE}"
sed -i '3s#.*#'"${PIC_POS}"'#' "${DATA_FILE}"
#-----------------NOTIFICATION-------------------------------------------#
dunstctl close-all
c_send "${SHOW_TYPE:-auto} - ${PIC_DIR}" "${PICS_L[${PIC_POS}]##*/}"

#################
) #-END-SUBSHELL#
#################
exit 0

