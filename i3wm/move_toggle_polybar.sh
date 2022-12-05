#!/bin/bash

CONFIG_DIR="$HOME/.config/polybar/configs/"
CONFIG_INI="$HOME/.config/polybar/config.ini"
LAUNCH_POLYBAR="$HOME/.config/polybar/launch.sh"

function move_polyz() {

    case "${1,,}" in
             left)  sed -i  's/^\([ \t]*\)offset[-]x/;\1offset-x/'                      "${CONFIG_INI}"
        ;;  right)  sed -i  's/^\([ \t]*\);\([ \t]*\)offset[-]x/\1\2offset-x/'          "${CONFIG_INI}"
        ;;     up)  sed -i  's/^[ \t]*bottom[ \t]*[=][ \t]*true/    bottom = false/'    "${CONFIG_INI}"  
        ;;   down)  sed -i  's/^[ \t]*bottom[ \t]*[=][ \t]*false/    bottom = true/'    "${CONFIG_INI}"
        ;;   hide)  killall "polybar"
        ;;   show)  ${LAUNCH_POLYBAR} & disown
        ;; toggle)  killall "polybar" || "${LAUNCH_POLYBAR}" & disown
        ;; config)  cp "${CONFIG_DIR}/${2}" "${CONFIG_INI}"
                    return "$?"
        ;;      *)  echo "ERROR: INVALID ARGUMENT, '${1}'">&2
                    return "1"
    esac

    if [[ -n "${2}" ]] ; then
        move_polyz "${@:2}"
    fi

    return "$?"
}

move_polyz "${@}"
