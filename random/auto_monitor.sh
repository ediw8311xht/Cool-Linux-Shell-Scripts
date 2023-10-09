#!/usr/bin/env bash

ORDER_MONITORS=('DP' 'HDMI' 'VGA' 'DVI' 'TV')

function get_monitors() {
    printf '%s\n' "$(xrandr --listmonitors | grep -Po "(?<= )(HDMI|VGA|DVI|DP|TV)[^\ ]+$")"
}

function rotate_m() {
    if xrandr  -q | grep -F "DP-1" | grep -Pio '[ \t]+\K[a-z]+(?=[ \t]*\()' ; then
        xrandr --output "${1}" --rotate "normal"
    else
        xrandr --output "${1}" --rotate "${2}"
    fi
    update_monitor_export
}

function update_monitor_export() {
    local hide_MONITORS=();
    local hide_Z='0'
    local gms=("$(get_monitors)")

    if [[ ! "${1,,}" =~ nox ]] && [[ -f "$HOME/.Xresources" ]] ; then
        local hide_Z="1" ; sed -i '/^i3\(wm\)\?[.]\(MONITOR\|monitor\).*/d' "$HOME/.Xresources"
    fi


    for i in "${ORDER_MONITORS[@]}" ; do
        if mon_g="$(grep -Pio "${i}[^ \t\n]*" <<< "${gms[@]}")" ; then
            echo "${mon_g}"
            hide_MONITORS+=("${mon_g}")
        fi
    done

    while [[ "$((++i))" -le "${#hide_MONITORS[@]}" ]] ; do
        export "MONITOR_${i}"="${hide_MONITORS[i-1]}"
        [[ "${hide_Z}" -eq '1' ]] && echo "i3wm.monitor${i}: ${hide_MONITORS[i-1]}" >> "$HOME/.Xresources"
        [[ "${i}"      -gt   0 ]] && xrandr --output "${hide_MONITORS[i-1]}" --right-of "${hide_MONITORS[i-2]}"
    done
}

function handle_args() {
    if [[ -z "${1}" ]] ; then
        update_monitor_export "${@}"
    else
        local a="${1}" ; shift 1
        case "${a}" in
               get) get_monitors
        ;;  rotate) rotate_m "${@}"
        ;;       *) update_monitor_export "${@}"
        ;; esac
    fi
}

handle_args "${@}"
