#!/bin/bash

polybar_manipulate_main() (
    CONFIG_DIR="$HOME/.config/polybar/configs/"
    CONFIG_INI="$HOME/.config/polybar/config.ini"
    DMENU_SCRIPT="$HOME/bin/my_dmenu.sh"
    DIS_MODE='all'

    launch_polybar() {
        if [[ -n "${DIS_MODE}" ]] ; then
            . "$HOME/.config/polybar/launch.sh" "${DIS_MODE}"
        else
            . "$HOME/.config/polybar/launch.sh"
        fi
    }
    config_select() {
        if [[ -f "${CONFIG_DIR}/${1}" ]] ; then
            killall "polybar"
            trash-put "${CONFIG_INI}"
            ln -s "${CONFIG_DIR}/${1}" "${CONFIG_INI}"
            launch_polybar & disown
        else
            echo "ERROR: Config not found '${CONFIG_DIR}/${1}'">&2
            exit 1
        fi
    }
    toggle_polybar() {
        if pgrep -x 'polybar' ; then
            killall "polybar"
        else
            launch_polybar "${DIS_MODE}" & disown
        fi
    }
    select_dmenu() {
        local choice=""
        if choice="$( find "${CONFIG_DIR}" -mindepth 1 -maxdepth 1 -type f -printf "%f\n" | "${DMENU_SCRIPT}" )" ; then
            config_select "${choice}"
        fi
    }
    error() {
        echo "ERROR: ${1}">&2
        exit 1
    }
    move_poly() {
        case "${1,,}" in
                     left)  sed -i --follow-symlinks 's/^\([ \t]*\)offset[-]x/;\1offset-x/'                      "${CONFIG_INI}"
            ;;      right)  sed -i --follow-symlinks 's/^\([ \t]*\);\([ \t]*\)offset[-]x/\1\2offset-x/'          "${CONFIG_INI}"
            ;;         up)  sed -i --follow-symlinks 's/^[ \t]*bottom[ \t]*[=][ \t]*true/    bottom = false/'    "${CONFIG_INI}"
            ;;       down)  sed -i --follow-symlinks 's/^[ \t]*bottom[ \t]*[=][ \t]*false/    bottom = true/'    "${CONFIG_INI}"
        esac
    }
    handle_args() {
        while [[ "${#}" -gt 0 ]] ; do
            case "${1,,}" in
                         move)  move_poly "${2}"; shift
                ;;        all)  DIS_MODE='all'
                ;;    primary)  DIS_MODE='primary'
                ;;  secondary)  DIS_MODE='secondary'
                ;;       show)  killall "polybar" ; launch_polybar & disown
                ;;       hide)  killall "polybar"
                ;;     toggle)  toggle_polybar
                ;;     config)  config_select "${2}"; shift
                ;;      dmenu)  select_dmenu
                                return "$?"
                ;;          *)  error "Invalid Argument"
            esac
            shift
        done
    }

    handle_args "${@}"
)

polybar_manipulate_main "${@}"
