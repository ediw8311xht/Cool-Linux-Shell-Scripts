#!/bin/bash

function hash_of() {
	SIZE="$#"
	echo $'\n' >$(tty)
	for i in "$@" ; do
		md5sum "${i}"
		SIZE=$((SIZE-1))
		echo -ne "#${SIZE}#\r     " >$(tty)
	done
	echo $'\n\n' >$(tty)
}

function file_hash() {
	if [[ -s "${2}" ]] ; then
		echo "FILE ALREADY EXISTS" ; return 1
    else
        G="$(hash_of ${1})"
        echo "${G}" > "${2}"
        return $?
	fi

}

function get_duplicates() {
	SORTED=($(cat "${1}" | sort))
	PORTED=($(cut -d ' ' -f 1 <<< "${SORTED[*]}"))
	SIZE="${#SORTED[@]}"
	i="1"
	while [[ "${i}" -lt $((SIZE-1)) ]] ; do
		Z="$(grep -P "^${PORTED[i]} " <<< "${SORTED[*]:$((i+1))}")"
        echo '----------------------------------------'
		echo "# ${Z}"
		if [[ "$?" -eq "0" ]] ; then
            echo ""
			echo "          -${SORTED[i]}-"
			trash-put --verbose "$(grep -Pio '^[^ ]+[ ]+\K.*' <<< "${SORTED[i]}")"
#			A="_"; read -p "Delete first or second file? (1|2|N)" A
#			if   [[ "$A" =~ ^1$ ]] ; then trash-put --verbose "$(grep -Pio '^[^ ]+[ ]+\K.*' <<< "${Z}")"
#			elif [[ "$A" =~ ^2$ ]] ; then trash-put --verbose "$(grep -Pio '^[^ ]+[ ]+\K.*' <<< "${SORTED[i]}")"
#			else
#				echo "SKIPPING"
#			fi
		fi
		i=$((i+1))
		#echo "HERE:  ${SORTED[i]}"
	done
}

function wrap_hash() {
	OLD_IFS="${IFS}"; IFS=$'\n'

	TEMP_F="$(mktemp "/tmp/XXXXXXX.txt")"

	FILES="$(find "$@" -type f)"

	file_hash "${FILES}" "${TEMP_F}"

	get_duplicates "${TEMP_F}"

	IFS="${OLD_IFS}"
	
	cat "${TEMP_F}"

	#rm "${TEMP_F}"

	return $?
}

wrap_hash "${@:1}"

