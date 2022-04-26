#!/bin/bash


c_send() {
	TIME="${4-"4000"}"; ICON="${8:-"$HOME/bin/Resources/Images/bluetooth.png"}"
	if [[ "${3}" = "E" ]] ; then MBG="${5:-"#000000"}"; MFG="${6-"#FF0000"}"; MFR="${7-"#FF0000"}"; 
	else 					     MBG="${5:-"#000000"}"; MFG="${6-"#00FF00"}"; MFR="${7-"#000000"}"; fi

	notify-send -i "${ICON}"\
				-h string:bgcolor:"${MBG}"\
				-h string:fgcolor:"${MFG}"\
				-h string:frcolor:"${MFR}"\
				-t "${TIME}"\
				"${1}" "${2}" 
}

/usr/bin/bluetooth on; if [[ "$?" -ne "0" ]] ; then c_send "ubluetoggle.sh" "> '/usr/bin/bluetooth on'" "E"; exit 1; fi
bluetoothctl power on; if [[ "$?" -ne "0" ]] ; then c_send "ubluetoggle.sh" "> 'bluetoothctl power on'" "E"; exit 1; fi

if [[ -n "${1}" ]] ; then
	DEVMAC="$(bluetoothctl paired-devices | grep -Pio "([0-9A-Z]{2}:){5}[0-9A-Z]{2}\ (?=${1})")"
else
	DEVMAC="$(bluetoothctl paired-devices | grep -Pio "([0-9A-Z]{2}:){5}[0-9A-Z]{2}")"
fi

if [[ "$?" -ne "0" ]] ; then
	c_send "Error" "Device with Mac Address for Device '${1-:"_any_"}' not found" "E"
	exit 1
fi

echo "${DEVMAC}"

ISMIS=$(bluetoothctl info | grep "Missing device address argument")

if [[ -n "${ISMIS}" ]]; then
	G="$(timeout "${2:-5}" bluetoothctl   connect 	  "${DEVMAC}")"
else                
	G="$(timeout "${2:-5}" bluetoothctl   disconnect 	  "${DEVMAC}")"
fi


if [[ "$?" -eq "124" ]] ; then
	c_send "ubluetoggle.sh" "Timeout > 'bluetoothctl conn/discon ${DEVMAC}'"$'\n'"${G}" "E"
else
	c_send "ubluetoggle.sh" "${G}"
fi
