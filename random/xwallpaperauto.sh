#!/bin/bash

###################
( #-BEGIN-SUBSHELL#
###################

#-----INIT---------------------------------------------------------------------#
IFS=$'\n'
DATA_FILE="$HOME/bin/Data/xwallautoDATA.txt"
touch "${DATA_FILE}"
if [[ "$(wc -l "${DATA_FILE}" | grep -o '^[0-9]*')" -lt 4 ]] ; then
    # IF DATA FILE IS EMPTY THEN ADD LINES
    echo $'\n\n\n\n\n\n\n' > "${DATA_FILE}"
fi

#-------------RESERVE-FIRST-LINE--#
main_dir="$(sed -n 2p "${DATA_FILE}")"
dpos="$(sed -n 3p "${DATA_FILE}")"
picpos="$(sed -n 4p "${DATA_FILE}")"
pargs="$(sed -n 5p "${DATA_FILE}")"

#-----CHECK--------------------------------------------------------------------#
[[            -d "${main_dir}" ]] || main_dir="$HOME/Pictures/Wallpapers"
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
    ;;  --pargs) if [[ "${got_t}" -ne '1' ]] ; then got_t='1' ;  pargs=( "${2}" )
                 else                                           pargs+=( "${2}" ) ; fi
    ;; esac
    shift && [[ "$#" -ge 1 ]] && handle_args "${@}"
}

#------------------------------------------------------------------------------#
#-----MAIN---------------------------------------------------------------------#
#------------------------------------------------------------------------------#
cd "${main_dir}" || exit 1
handle_args "${@}"

ldirs=(); mapfile -t "ldirs" < <(dirs_with_pics '.' '-quit' | sort)
[[ "$(( dpos %= "${#ldirs[@]}" ))" -ge 0 ]] || (( dpos += "${#ldirs[@]}" ))
lpics=(); mapfile -t "lpics" < <(bash -c -- "${picfind}" - "${ldirs[ "${dpos}" ]}" | sort)
[[ "$(( picpos %= "${#lpics[@]}" ))" -ge 0 ]] || (( picpos += "${#lpics[@]}" ))

#-----CHANGE-WALLPAPER---------------------------------------------------------#
if [[ -z "${OUTPUTS[*]}" ]] ; then
    for i in $(xrandr --listmonitors | grep -Pio "^[ \t]*[0-9]+[:].*[ ]\K[^ ]+$") ; do
        xwallpaper --output "${i}" "${pargs[*]:---focus}" "${lpics[ "${picpos}" ]}"
    done
else
    xwallpaper "${OUTPUTS[*]}" $(printf '%s' "${pargs[*]:---focus}") "${lpics[ "${picpos}" ]}"
fi

#-----UPDATE-DATA-FILE---------------------------------------------------------#
sed -i '2s#.*#'"${main_dir}"'#'  "${DATA_FILE}"
sed -i '3s#.*#'"${dpos}"'#'      "${DATA_FILE}"
sed -i '4s#.*#'"${picpos}"'#'    "${DATA_FILE}"
sed -i '5s#.*#'"${pargs[*]}"'#'     "${DATA_FILE}"

#-----NOTIFICATION-------------------------------------------------------------#
if [[ -z "${SILENT}" ]] ; then
    dunstctl close-all
    string="$(printf $'%s \n'                     \
              "xwallpaper [${pargs[*]:---focus}]" \
              "[${dpos}] - ${ldirs[dpos]}"        \
              "[${picpos}] - ${lpics[${picpos}]##*/}" )"
    notify-send -h string:bgcolor:"#000000" -h string:fgcolor:"#00FF00"     \
                -h string:frcolor:"#00FF00" -t "10000" "${string}"
    echo "HI"
fi

#################
) #-END-SUBSHELL#
#################

