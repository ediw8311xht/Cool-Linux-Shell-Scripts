#!/bin/bash

polybar_manipulate_main() (
    CONFIG_DIR="$HOME/.config/polybar/configs/"
    CONFIG_INI="$HOME/.config/polybar/config.ini"
    DIS_MODE='all'

    launch_polybar() {
        if [[ -n "${DIS_MODE}" ]] ; then
            . "$HOME/.config/polybar/launch.sh" "${DIS_MODE}"
        else
            . "$HOME/.config/polybar/launch.sh"
        fi
    }

    move_polyz() {

        case "${1,,}" in
                     left)  sed -i --follow-symlinks 's/^\([ \t]*\)offset[-]x/;\1offset-x/'                      "${CONFIG_INI}"
            ;;      right)  sed -i --follow-symlinks 's/^\([ \t]*\);\([ \t]*\)offset[-]x/\1\2offset-x/'          "${CONFIG_INI}"
            ;;         up)  sed -i --follow-symlinks 's/^[ \t]*bottom[ \t]*[=][ \t]*true/    bottom = false/'    "${CONFIG_INI}"
            ;;       down)  sed -i --follow-symlinks 's/^[ \t]*bottom[ \t]*[=][ \t]*false/    bottom = true/'    "${CONFIG_INI}"

            ;;        all)  DIS_MODE='all'
            ;;    primary)  DIS_MODE='primary'
            ;;  secondary)  DIS_MODE='secondary'

            ;;       show)  killall "polybar" ; launch_polybar & disown
            ;;       hide)  killall "polybar"
            ;;     toggle)  killall "polybar" || launch_polybar "${DIS_MODE}" & disown
            ;;     config)  killall "polybar"; trash-put "${CONFIG_INI}"; ln -s "${CONFIG_DIR}/${2}" "${CONFIG_INI}"; launch_polybar & disown
                            return "$?"

            ;;          *)  echo "ERROR: INVALID ARGUMENT, '${1}'">&2
                            return 1
        esac

        if [[ -n "${2}" ]] ; then
            move_polyz "${@:2}"
        fi
    }

    move_polyz "${@}"
)

polybar_manipulate_main "${@}"
