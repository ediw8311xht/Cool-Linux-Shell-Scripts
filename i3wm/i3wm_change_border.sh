#!/bin/bash

####################
( #-START-SUBSHELL-#
####################

set -eu

DIR_I3="${HOME}/.config/i3/"
DIR_I3_BORDER='borders/'
DIR_I3_COMP="${DIR_I3}/${DIR_I3_BORDER}/"
XREC_FILE="${HOME}/.Xresources"
XREC_VAR='i3wm.BORDER_FILE'


write_xrec() {
    echo "${1}"
    if grep -q "^${XREC_VAR}:" "${XREC_FILE}" ; then
        sed -i -E "s#^(${XREC_VAR}:).*#\1 ${DIR_I3_BORDER}${1}#" "${XREC_FILE}"
    else
        echo "${XREC_VAR} not defined in ${XREC_FILE}"
        exit 1
    fi
}


swap_border() {
    local BFILE=''
    local DM_FONT='Office Code Pro:pixelsize=17:antialias=true:autohint=true'

    if [[ -d "${DIR_I3}" ]] && [[ -d "${DIR_I3_COMP}" ]] ; then
        cd "${DIR_I3_COMP}"
        BFILE="$(dmenu -b -i -nf '#00FF00' -nb '#000000' -l 10 -fn "${DM_FONT}" \
            < <(find . -type f -iname "border*" -printf '%f\n'))"
        [[ ! -f "${BFILE}" ]] && exit 0
        write_xrec "${BFILE}"
    else
        echo "ERROR IN SWAP BORDER:"
        echo -e "\t ${!DIR_I3*}"
        echo -e "\t'${DIR_I3}', '${DIR_I3_BORDER}', or '${DIR_I3_COMP}'"
        exit 1
    fi
}

main() {
    swap_border
    xrdb "${XREC_FILE}"
    i3 -C "${DIR_I3}/config/"
    i3-msg 	"reload; restart"
}


main

####################
) #---END-SUBSHELL-#
####################

