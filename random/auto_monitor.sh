#!/usr/bin/env bash

get_monitors() {
    xrandr --listmonitors | grep -Po "(?<= )(HDMI|VGA|DVI|DP|TV|DisplayPort)[^\ ]+$"
}

rotate_m() {
    local ROTATE_MONITOR="${1}.*"
    if xrandr  -q | grep -Pio "${ROTATE_MONITOR}" | grep -Pio '(left|right)[ \t]*[(]' ; then
        xrandr --output "${1}" --rotate "normal"
    else
        xrandr --output "${1}" --rotate "${2}"
    fi
    update_monitor_export
    "${HOME}/bin/xwallpaperauto.sh" --silent
}

update_monitor_export() {
    local ORDER_MONITORS=('DP' 'DisplayPort' 'HDMI' 'VGA' 'DVI' 'TV')
    local ORDER_MONITORS=('HDMI-2' 'DP' 'HDMI-3')
    local primary='DP'
    local MONS gmon lmon i
    MONS="$(get_monitors)"

    [[ ! -f "${HOME}/.Xresources" ]] && return 1

    sed -i '/^i3wm[.]\(primary\|other\)_monitor.*/Id' "$HOME/.Xresources"

    for cm in "${ORDER_MONITORS[@]}" ; do
        gmon="$(grep -i "${cm}" <<< "${MONS}")"

        [[ -z "${gmon}" ]] && continue

        [[ -n "${lmon}" ]] && xrandr --output "${gmon}" --right-of "${lmon}"

        lmon="${gmon}"

        if [[ "${gmon}" = *"${primary}"* ]] ; then
            xrandr --output "${gmon}" --primary
            echo "i3wm.primary_monitor: ${gmon}" >> "$HOME/.Xresources"
            export PRIMARY_MONITOR="${gmon}"
        else
            echo "i3wm.other_monitor_$((++i)): ${gmon}" >> "$HOME/.Xresources"
            export MON_${i}="${gmon}"
        fi
    done
}

handle_args() {
    local a="${1}" ; shift 1
    case "${a}" in
           get) get_monitors
    ;;  rotate) rotate_m "${@}"
    ;;       *) update_monitor_export "${@}"
    ;; esac
    [[ -z "${*}" ]] && return 0
    handle_args "${@}"
}

handle_args "${@}"
