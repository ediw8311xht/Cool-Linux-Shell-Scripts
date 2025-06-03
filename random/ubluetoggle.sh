#!/bin/bash

c_send() {
    local ICON="${HOME}/bin/Resources/Images/bluetooth.png"
    notify-send -i "${ICON}" -a "${1}" "${@:2}"
}
ubluetoggle() {
    if ! systemctl --quiet is-active bluetooth ; then
        c_send "ubluetoggle.sh" "Bluetooth not enabled"
        return 1
    fi

    local DEVMAC="${BLUETOOTH_DEVICE_1_MAC}"
    local IS_CON="connect"
    local OUT=""
    local TIMEOUT="5"

    { bluetoothctl info | grep "Missing device address argument"; } ||
        IS_CON="disconnect"

    if ! OUT="$(timeout "${TIMEOUT}" bluetoothctl ${IS_CON} "${DEVMAC}")" ; then
        c_send "ubluetoggle.sh" "Error: ${OUT}"
        return 1
    fi
    c_send "ubluetoggle.sh" "Success: ${OUT}"
    return 0
}

ubluetoggle "${@}"
