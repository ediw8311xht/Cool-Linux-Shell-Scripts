#!/bin/bash

CONFIG_INI="$HOME/.config/polybar/config.ini"
LAUNCH_POLYBAR="$HOME/.config/polybar/launch.sh"

function move_polyz() {

    if [[ -z "${1}" ]] ; then   echo "HI"; return "0"
    else                        echo "BYE"; CHECK="${1,,}"  ; fi

    case "${CHECK}" in
             left)  sed -i  's/^\([ \t]*\)offset[-]x/;\1offset-x/'                      "${CONFIG_INI}"
        ;;  right)  sed -i  's/^\([ \t]*\);\([ \t]*\)offset[-]x/\1\2offset-x/'          "${CONFIG_INI}"
        ;;     up)  sed -i  's/^[ \t]*bottom[ \t]*[=][ \t]*true/    bottom = false/'    "${CONFIG_INI}"  
        ;;   down)  sed -i  's/^[ \t]*bottom[ \t]*[=][ \t]*false/    bottom = true/'    "${CONFIG_INI}"
        ;;   hide)  killall "polybar" & disown
        ;;   show)  ${LAUNCH_POLYBAR} & disown
        ;; toggle)  killall "polybar" || "${LAUNCH_POLYBAR}"
        ;;      *)  echo "ERROR: INVALID ARGUMENT">&2
                    return "1"
    esac

    move_polyz "${@:2}"
}

move_polyz "${@}"

