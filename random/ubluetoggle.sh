#!/bin/bash


/usr/bin/bluetooth on
bluetoothctl power on

DEVMAC=$(bluetoothctl paired-devices | grep -Po "[0-9|A-Z]{2}(:[0-9|A-Z]{2}){5}")

echo "${DEVMAC}"

ISMIS=$(bluetoothctl info | grep "Missing device address argument")


if [[ -n $ISMIS ]]; then
# Controller is Off
	DAT=$(bluetoothctl connect $DEVMAC) 
else
	DAT=$(bluetoothctl disconnect $DEVMAC)
fi

notify-send "ubluetoggle.sh" "$DAT"
