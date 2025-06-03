#!/bin/bash

c_send() {
    local ICON="${HOME}/bin/Resources/Images/bluetooth.png"
    notify-send -i "${ICON}" -a "${1}" "${@:2}"
}
ubluetoggle() {
    local DEVMAC="${BLUETOOTH_DEVICE_1_MAC}"
    local IS_CON="disconnect"


    if ! systemctl --quiet is-active bluetooth ; then
        c_send "ubluetoggle.sh" "Bluetooth not enabled"
    fi

    if bluetoothctl info | grep "Missing device address argument" ; then
        IS_CON="connect"
    fi


    if ! G="$(timeout "${TIMEOUT}" bluetoothctl ${IS_CON} "${DEVMAC}")" ; then
        c_send "ubluetoggle.sh" "Error: ${G}"
    else
        c_send "ubluetoggle.sh" "Success: ${G}"
    fi
}

ubluetoggle "${@}"
