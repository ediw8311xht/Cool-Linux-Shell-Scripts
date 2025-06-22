#!/bin/bash

# shellcheck disable=SC2120
polybar_manipulate_main() {
    local CONFIG_DIR="$HOME/.config/polybar/configs/"
    local CONFIG_INI="$HOME/.config/polybar/config.ini"
    local DMENU_SCRIPT="$HOME/bin/my_dmenu.sh"
    local DIS_MODE='all'
 
    xrec_get() { xrdb -get "${1}" | grep "."; }
    xrec_set() { xrdb -override <<< "${1:-"NONE"}"; }
    polybar_kill_one() {
        local OTHER
        if ! OTHER="$(xrec_get "${1}")" ; then
            return 1
        elif [[ "${OTHER}" =~ ^[0-9]+$ ]] ; then
            kill "${OTHER}" || return 2
        else
            return 3
        fi
    }
    polybar_kill_all() {
        local i=1
        local max_total="${1:-"20"}"
        while [[ $((max_total--)) -ge 1 ]] ; do
            polybar_kill_one "i3wm.primary_monitor_pid"
            polybar_kill_one "i3wm.other_monitor_${i}_pid"
            case "${?}" in
                  0|3) ((i++))
            ;;      2) continue
            ;;      *) return 0
            esac
        done
        killall "polybar"
        return 1
    }

    launch_polybar() {
        local PRIMARY=''
        local OTHER=''
        local i=1

        polybar_kill_all

        if PRIMARY="$(xrec_get 'i3wm.primary_monitor')" ; then
            MONITOR="${PRIMARY}" polybar --reload primarybar & disown
            xrec_set "i3wm.primary_monitor_pid: ${!}"
        fi

        while OTHER="$(xrec_get "i3wm.other_monitor_${i}")" && [[ -n "${OTHER}" ]] ; do
            MONITOR="${OTHER}" polybar --reload secondarybar & disown
            xrec_set "i3wm.other_monitor_${i}_pid: ${!}"
            ((i++))
        done
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
            polybar_kill_all "polybar"
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
            ;;     launch)  launch_polybar
            ;;        all)  DIS_MODE='all'
            ;;    primary)  DIS_MODE='primary'
            ;;  secondary)  DIS_MODE='secondary'
            ;;       show)  killall "polybar" ; launch_polybar & disown
            ;;       hide)  killall "polybar"
            ;;     toggle)  toggle_polybar "all"
            ;;     config)  config_select "${2}"; shift
            ;;      dmenu)  select_dmenu ; return
            ;;          *)  error "Invalid Argument" ; return 1
            esac
            shift
        done
    }

    handle_args "${@}"
}

polybar_manipulate_main "${@}"
