#!/bin/bash

# shellcheck disable=SC2120
main() { #---------- START ------------------#

local BARS
local CONFIG_DIR="$HOME/.config/polybar/configs/"
local CONFIG_INI="$HOME/.config/polybar/config.ini"
local DMENU_SCRIPT="$HOME/bin/my_dmenu.sh"
local DEFAULT_BAR="secondarybar"

declare -A BARS
BARS["i3wm.primary_monitor"]="primarybar"
BARS["i3wm.other_monitor_1"]="secondarybar"
BARS["i3wm.other_monitor_2"]="secondarybar"

xrec_get() { xrdb -get "${1}" | grep "."; }
xrec_set() { xrdb -override <<< "${1}"; }
xrec_query_parse() { xrdb -query | sed --sandbox -nE "s/${1}/${2}/p"; }

xrec_get_mons() {
    xrec_query_parse '^(i3wm[.][^:]*monitor(_[0-9]+)?)[:]\s*(.*)\s*$' '\1 \3'
}

xrec_set_none() {
    xrdb -override \
        < <(xrec_query_parse '^(i3wm[.][^:]*_monitor_pid[:]\s)(.*)$' '\1NONE')
}

pl_kill() {
    local OTHER
    if OTHER="$(xrdb -get "${1}_pid" | grep -Pox '\s*[0-9]+\s*')" ; then
        xrec_set "${1}_pid: NONE"
        polybar-msg -p "${OTHER}" "cmd" "quit" 
        return $?
    else
        return 1
    fi
}

pl_toggle_dmenu() { 
    local NAME VALUE
    if read -r NAME VALUE < <( "${DMENU_SCRIPT}" < <(xrec_get_mons) ) ; then
        toggle_polybar "${NAME}" "${VALUE}"
    else
        return 1
    fi
}

pl_kill_all() { polybar-msg "cmd" "quit" && xrec_set_none; }

pl_launch() {
    MONITOR="${1}" nohup polybar --reload "${BARS["${2}"]:-"${DEFAULT_BAR}"}" > /dev/null & disown
    xrec_set "${2}_pid: ${!}"
}

pl_launch_all() {
    local name; local value

    pl_kill_all

    while read -r -d $'\n' name value ; do
        pl_launch "${value}" "${name}"
    done < <(xrec_get_mons)
}
config_select() {
    if [[ -f "${CONFIG_DIR}/${1}" ]] ; then
        killall "polybar"
        trash-put "${CONFIG_INI}"
        ln -s "${CONFIG_DIR}/${1}" "${CONFIG_INI}"
        pl_launch_all & disown
    else
        exit 1
    fi
}
toggle_polybar() {
    [[ "${1,,}" = 'all' ]] && { pl_kill_all || pl_launch_all; return $?; }
    echo "${1} ${2}"
    pl_kill "${1}" || pl_launch "${2}" "${1}"

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
             left)  sed -Ei --follow-symlinks 's/^(\s*)(offset[-]x)/;\1\2/'            "${CONFIG_INI}"
    ;;      right)  sed -Ei --follow-symlinks 's/^(\s*);(\s*)(offset[-]x)/\1\2\3/'     "${CONFIG_INI}"
    ;;         up)  sed -Ei --follow-symlinks 's/^(\s*bottom\s*[=]\s*)(true)/\1false/' "${CONFIG_INI}"
    ;;       down)  sed -Ei --follow-symlinks 's/^(\s*bottom\s*[=]\s*)(false)/\1true/' "${CONFIG_INI}"
    esac
}
handle_args() {
    while [[ "${#}" -gt 0 ]] ; do
        case "${1,,}" in
                 move)  move_poly "${2}"; shift
        ;;     launch)  pl_launch_all ; return
        # ;;        all)  DIS_MODE='all'
        # ;;    primary)  DIS_MODE='primary'
        # ;;  secondary)  DIS_MODE='secondary'
        ;;       show)  pl_launch_all ; return
        ;;       hide)  pl_kill_all   ; return
        ;;     toggle)  toggle_polybar 'all' ; return
        ;;     config)  config_select "${2}"; shift
        ;;      dmenu)  select_dmenu    ; return
        ;;     tdmenu)  pl_toggle_dmenu ; return
        ;;          *)  error "Invalid Argument" ; return 1
        esac
        shift
    done
}

handle_args "${@}"


} #---------------------------- END ----------------------------#

main "${@}"
