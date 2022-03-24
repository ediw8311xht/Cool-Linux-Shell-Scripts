#!/bin/bash


if [[ ! "${USER}" = "root" ]] ; then
	echo "YOU MUST RUN THIS PROGRAM USING SUDO"
	exit 1
fi

DATAFILE="/home/$SUDO_USER/bin/Data/auto_mount_data.txt"

OLD="${IFS}"; IFS=$'\n'; FG=($(cat "${DATAFILE}"))
IFS="${OLD}"

for key in "${FG[@]}"
do
	LK=(${key})
	if [[ ! "${LK[0]}" =~ ^#.* ]] ; then
		if [[ "${LK[0]}" = "mount" ]] ; then
			echo "mount UUID=\"${LK[1]}\" \"${LK[2]}\""
			mount UUID="${LK[1]}" "${LK[2]}"
		elif [[ "${LK[0]}" = "unmount" ]] || [[ "${LK[1]}" = "umount" ]] ; then
			echo "umount UUID=\"${LK[1]}\" \"${LK[2]}\""
			umount UUID="${LK[1]}" "${LK[2]}"
		fi
	fi
done

