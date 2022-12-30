#!/bin/bash

###################
( #-BEGIN-SUBSHELL#
###################

#-----INIT---------------------------------------------------------------------#
IFS=$'\n'
DATA_FILE="$HOME/bin/Data/xwallautoDATA.txt"
touch "${DATA_FILE}"
if [[ "$(wc -l "${DATA_FILE}" | grep -o '^[0-9]*')" -lt 3 ]] ; then
    echo $'\n\n\n' > "${DATA_FILE}"
fi

main_dir="$(sed -n 1p "${DATA_FILE}")"
dpos="$(sed -n 2p "${DATA_FILE}")"
picpos="$(sed -n 3p "${DATA_FILE}")"

#-----CHECK--------------------------------------------------------------------#
[[           -d "${main_dir}"  ]] || main_dir="$HOME/Pictures"
[[   "${dpos}" =~ ^[-]?[0-9]+$ ]] || dpos=0
[[ "${picpos}" =~ ^[-]?[0-9]+$ ]] || picpos=0

#-----FUNCTIONS----------------------------------------------------------------#
picfind='find "${1}" -mindepth 1 -maxdepth 1 -type f -iregex ".*[.]\(png\|jpg\|jpeg\)"' 
function dirs_with_pics() {
    find "${1}" -mindepth 1 -maxdepth 1 -type d \
        -execdir bash -c -- "${picfind}"' -exec echo "${1#./*}" \; -quit' - {} \;       
}
function handle_args() {
    case "${1,,}" in 
        left) picpos=0 ; ((dpos--))
    ;; right) picpos=0 ; ((dpos++))
    ;;    up) ((picpos--)) 
    ;;  down) ((picpos++))
    ;; --silent) SILENT=1
    ;; --output) OUTPUTS+=("${2}") ; shift
    ;;  --pargs) PARGS+=("${2}")   ; shift
    ;; esac
    shift && [[ "$#" -ge 1 ]] && handle_args "${@}"
}

#------------------------------------------------------------------------------#
#-----MAIN---------------------------------------------------------------------#
#------------------------------------------------------------------------------#
cd "${main_dir}" || exit 1
handle_args "${@}"

ldirs=(); mapfile -t "ldirs" < <(dirs_with_pics '.' '-quit' | sort)
[[ $(( dpos %= ${#ldirs[@]} )) -ge 0 ]] || (( dpos += ${#ldirs[@]} ))
lpics=(); mapfile -t "lpics" < <(bash -c -- "${picfind}" - "${ldirs[ dpos ]}" | sort)
[[ $(( picpos %= ${#lpics[@]} )) -ge 0 ]] || (( picpos += ${#lpics[@]} ))

#-----CHANGE-WALLPAPER---------------------------------------------------------#
if [[ -z "${OUTPUTS[*]}" ]] ; then
    for i in $(xrandr --listmonitors | grep -Po "(?<= )(HDMI|VGA|DVI)[^ ]+$") ; do
        xwallpaper --output "${i}" ${PARGS[*]:---focus} "${lpics[ picpos ]}"
    done
else
    xwallpaper ${OUTPUTS[*]} ${PARGS[*]:---focus} "${lpics[ picpos ]}"
fi

#-----UPDATE-DATA-FILE---------------------------------------------------------#
sed -i '1s#.*#'"${main_dir}"'#'  "${DATA_FILE}"
sed -i '2s#.*#'"${dpos}"'#'      "${DATA_FILE}"
sed -i '3s#.*#'"${picpos}"'#'    "${DATA_FILE}"

#-----NOTIFICATION-------------------------------------------------------------#
if [[ -z "${SILENT}" ]] ; then
    dunstctl close-all
    string="$(printf $'%s \n'                     \
              "xwallpaper [${PARGS[*]:---focus}]" \
              "[${dpos}] - ${ldirs[dpos]}"        \
              "[${picpos}] - ${lpics[${picpos}]##*/}" )"
    notify-send -h string:bgcolor:"#000000" -h string:fgcolor:"#00FF00"     \
                -h string:frcolor:"#00FF00" -t "10000" "${string}"
fi

########################################
) ; exit 0 #-END-SUBSHELL---AND-PROGRAM#
########################################

