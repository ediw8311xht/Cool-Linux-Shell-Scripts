#!/bin/bash

function get_monitors() {
    printf '%s\n' "$(xrandr --listmonitors | grep -Po "(?<= )(HDMI|VGA|DVI)[^\ ]+$")"
}

function update_monitor_export() {
    local hide_MONITORS=();
    local hide_Z='0'

    if [[ ! "${1,,}" =~ nox ]] && [[ -f "$HOME/.Xresources" ]] ; then
        echo "HI"
        local hide_Z="1" ; sed -i '/^i3\(wm\)?[.]\(MONITOR\|monitor\).*/d' "$HOME/.Xresources"
    fi
    mapfile -t hide_MONITORS < <(get_monitors | sort)
    i='0' ; while [[ ++i -le "${#hide_MONITORS[@]}" ]] ; do
        export "monitor${i}"="${hide_MONITORS[i]}"
        if [[ "${hide_Z}" -eq '1' ]] ; then
            echo "i3wm.monitor${i}: ${hide_MONITORS[i-1]}" >> "$HOME/.Xresources"
            echo "BYE"
        fi
    done
}

update_monitor_export "${@}"
