#!/bin/bash

####################
( #-START-SUBSHELL-#
####################

IFS=$'\n'
L_DIRS=()
L_PICS=()
SILENT='0'
DATA_FILE="$HOME/bin/Data/xwallautoDATA.txt"

notify_wallpaper_change() {
    dunstctl close-all
    notify_args=(
        -h string:bgcolor:"#000000"
        -h string:fgcolor:"#00FF00"
        -h string:frcolor:"#00FF00"
        -t "10000"
    )
    string=(
        "xwallpaper [${PARGS[*]:---focus}]"
        "${DPOS} - ${L_DIRS[DPOS]##*/}"
        "${PICPOS} - ${L_PICS[${PICPOS}]##*/}"
    )
    notify-send "${notify_args[@]}" "${string[*]}"
}

init_data_file() {
    touch "${DATA_FILE}"
    if [[ "$(wc -l <"${DATA_FILE}")" -lt 4 ]] ; then
        echo $'\n\n\n\n\n\n\n' > "${DATA_FILE}" # IF DATA FILE IS EMPTY THEN ADD LINES
    fi
}

#-------------RESERVE-FIRST-LINE--#
read_from_data_file() {
    MAIN_DIR="$(    sed -n 2p "${DATA_FILE}"   )"
    DPOS="$(        sed -n 3p "${DATA_FILE}"   )"
    PICPOS="$(      sed -n 4p "${DATA_FILE}"   )"
    PARGS="$(       sed -n 5p "${DATA_FILE}"   )"
    [[        -d "${MAIN_DIR}" ]] || MAIN_DIR="$HOME/Pictures/Wallpapers"
    [[   "${DPOS}" =~ ^[0-9]+$ ]] || DPOS=0
    [[ "${PICPOS}" =~ ^[0-9]+$ ]] || PICPOS=0
}

update_data_file() {
    sed -i '2s#.*#'"${MAIN_DIR}"'#'  "${DATA_FILE}"
    sed -i '3s#.*#'"${DPOS}"'#'      "${DATA_FILE}"
    sed -i '4s#.*#'"${PICPOS}"'#'    "${DATA_FILE}"
    sed -i '5s#.*#'"${PARGS[*]}"'#'   "${DATA_FILE}"
}

pic_find() {
    find "${1}" \( -iname '*.png' -o -iname '*.jpg' \) -printf '%p\n' | sort | uniq
}

dirs_with_pics() {
    find "${MAIN_DIR}" -mindepth 1 -maxdepth 2 \( -iname '*.png' -o -iname '*.jpg' \) -printf '%h\n' | sort | uniq
}

handle_args() {
    case "${1,,}" in
           left) PICPOS=0 ; ((DPOS--))
    ;;    right) PICPOS=0 ; ((DPOS++))
    ;;       up) ((PICPOS++))
    ;;     down) ((PICPOS--))
    ;; --silent) SILENT=1
    ;;  --pargs) PARGS=( "${2}" ); shift 1
    ;; esac
    shift 1
    [[ "$#" -ge 1 ]] && handle_args "${@}"
}

main() {
    init_data_file
    read_from_data_file
    handle_args "${@}"

    mapfile -t "L_DIRS" < <(dirs_with_pics)
    [[ "$(( DPOS %= "${#L_DIRS[@]}" ))" -ge 0 ]] || (( DPOS += "${#L_DIRS[@]}" ))

    mapfile -t "L_PICS" < <(pic_find "${L_DIRS[ "${DPOS}" ]}")
    [[ "$(( PICPOS %= "${#L_PICS[@]}" ))" -ge 0 ]] || (( PICPOS += "${#L_PICS[@]}" ))

    #-----CHANGE-WALLPAPER---------------------------------------------------------#
    xwallpaper "${PARGS[@]:---focus}" "${L_PICS[ "${PICPOS}" ]}"

    #-----UPDATE-DATA-FILE---------------------------------------------------------#
    update_data_file
    #-----NOTIFICATION-------------------------------------------------------------#
    if [[ "${SILENT}" -eq 0 ]] ; then
        notify_wallpaper_change
    fi
}

main "${@}"
####################
) #---END-SUBSHELL-#
####################

