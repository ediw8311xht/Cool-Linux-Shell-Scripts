#!/bin/bash

# shellcheck disable=SC2120
polybar_manipulate_main() { #---------- START ------------------#

local CONFIG_DIR="$HOME/.config/polybar/configs/"
local CONFIG_INI="$HOME/.config/polybar/config.ini"
local DMENU_SCRIPT="$HOME/bin/my_dmenu.sh"
local DIS_MODE='all'

xrec_get() { xrdb -get "${1}" | grep "."; }
xrec_set() { xrdb -override <<< "${1}"; }
xrec_query_parse() { xrdb -query | sed --sandbox -nE "s/${1}/${2}/p"; }
xrec_get_mons() {
    xrec_query_parse '^(i3wm[.][^:]*monitor(_[0-9]+)?)[:]\s*(.*)\s*$' '\1 \3'
}
xrec_set_none() {
    xrdb -override \
        < <(xrec_query_parse '^(i3wm[.][^:]*_monitor[^:]*_pid[:]\s)(.*)$' '\1NONE')
}
polybar_kill_one() {
    local OTHER
    if OTHER="$(xrdb -get "${1}" | grep -Pox '\s*[0-9]+\s*')" ; then
        polybar-msg -P "${OTHER}" "quit"
    fi
}
polybar_kill_all() {
    polybar-msg "cmd" "quit" && xrec_set_none
}

launch_polybar() {
    local name
    local value

    polybar_kill_all

    while read -r -d $'\n' name value ; do
        if [[ "${name}" =~ "primary" ]] ; then
            MONITOR="${value}" nohup polybar --reload primarybar > /dev/null & disown
        else
            MONITOR="${value}" nohup polybar --reload secondarybar > /dev/null & disown
        fi
        xrec_set "${name}_pid: ${!}"
    done < <(xrec_get_mons)
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
        polybar_kill_all
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
        ;;       show)  launch_polybar
        ;;       hide)  polybar_kill_all
        ;;     toggle)  toggle_polybar
        ;;     config)  config_select "${2}"; shift
        ;;      dmenu)  select_dmenu ; return
        ;;          *)  error "Invalid Argument" ; return 1
        esac
        shift
    done
}

handle_args "${@}"


} #---------------------------- END ----------------------------#

polybar_manipulate_main "${@}"
