#!/bin/bash

CONFIG_DIR="$HOME/.config/polybar/configs/"
CONFIG_INI="$HOME/.config/polybar/config.ini"
MY_PANELS=( 'polybar' 'xfce4-panel' 'mate-panel' 'taffybar' )

function is_up() {
    pgrep -x "${1}" \
        && return 0 \
        || return 1
}

function ak47() {
    while [[ "${i:=0}" -lt "${#MY_PANELS[@]}" ]] ; do
            is_up "${MY_PANELS[i]}" \
            && pkill -x "${MY_PANELS[i]}" \
            && echo "${i}" \
            || (( i++ ))     
        # __ a && b && c || d __ prevent infinite loop if pkill fails
    done
}

function lunch() {
    [[ "${1}" -ge 1 ]] \
    && [[ "${1}" -lt "${#MY_PANELS[@]}" ]] \
    && ${MY_PANELS[1]}
}

function move_polyz() {
    mapfile -d '\0' tzbreezy < <( ak47 | grep -Pzo '(?<=^|[ ])[0-9]*(?=$|[ ])' )

    case "${1,,}" in
                 left)  sed -i  's/^\([ \t]*\)offset[-]x/;\1offset-x/'                      "${CONFIG_INI}"
        ;;      right)  sed -i  's/^\([ \t]*\);\([ \t]*\)offset[-]x/\1\2offset-x/'          "${CONFIG_INI}"
        ;;         up)  sed -i  's/^[ \t]*bottom[ \t]*[=][ \t]*true/    bottom = false/'    "${CONFIG_INI}"  
        ;;       down)  sed -i  's/^[ \t]*bottom[ \t]*[=][ \t]*false/    bottom = true/'    "${CONFIG_INI}"

        ;;        all)  DIS_MODE='all'
        ;;    primary)  DIS_MODE='primary'
        ;;  secondary)  DIS_MODE='secondary'

        ;;       show)  a="$(auto_kill)" ; lunch & disown
        ;;       hide)  ak47 
        ;;     toggle)  ak47 || lunch & disown
        ;;      xfce4)  ak47 ;  xfce4-panel
        ;;     config)  cp "${CONFIG_DIR}/${2}" "${CONFIG_INI}"
                        return "$?"

        ;;          *)  echo "ERROR: INVALID ARGUMENT, '${1}'">&2
                        return "1"
    esac

    if [[ -n "${2}" ]] ; then
        move_polyz "${@:2}"
    fi

    return "$?"
}

move_polyz "${@}"

