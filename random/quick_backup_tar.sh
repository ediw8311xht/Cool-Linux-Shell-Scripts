#!/bin/bash

DEFAULT="${HOME}/bin/Data/files_to_backup.txt"
DEFAULT_OUT="${AUTOBACKUP:-./}"

human_readable() {
	echo $(echo "${1}" | numfmt --to=iec)
}

get_size() {
	echo "$(du -s $1 | grep -Po '^[1-9][0-9]*')"
}

mtar_back() {
	if [[ -n "${1}" ]] ; then 
		if [[ -f "${2}" ]] || [[ -d "$2" ]] ; then
			echo $(tar --exclude-caches -czf "${1}" "${2}")
			echo ""
			echo "========COMPRESSED FILE/DIR ( $2 )"
			echo "========OUTPUT 	  TARFILE ( $1 )"
		else
			echo "--->SKIPPED FILE/DIR ( $2 ): COULD NOT BE FOUND"
		fi
	else
		echo 	 "--->SKIPPED FILE/DIR ( $2 ): INVALID ARGUMENT"
	fi
}

arg_getter() {
	if [[ -f "${1}" ]] ; then
		return 0
	elif [[ -d "${1}" ]] ; then
		return 1
	fi
	return 2
}

arg_getter "${1}"; if [[ "$?" = "0" ]] ; then DEFAULT="${1}"; fi
arg_getter "${2}"; if [[ "$?" = "1" ]] ; then DEFAULT_OUT="${2}"; fi

IFS=$'\n'
LTE=$(cat "${DEFAULT}")
echo "read from: ${DEFAULT}"
echo "outputting to: ${DEFAULT_OUT}"
echo $'\n\n'

N=0; U=0; C=0

for pte in ${LTE[@]} ; do
	echo "${pte}"
	if [[ "${pte}" =~ ^\#.* ]] ; then
		echo 	 "####SKIPPED FILE/DIR ( $pte ); COMMENTED OUT"
	else
		dt=$(date '+BACKUP_%Y_%m_%d_%H%M__')
		noslash="${pte//\//\-}"
		tarfile="${DEFAULT_OUT}${dt}${noslash}.tar.gz"
		OUTPUT=$(mtar_back "${tarfile}" "${pte}")
		echo "${OUTPUT}" 
		A="$(get_size $pte)"
		B=$(get_size "${tarfile}")

		N=$(( "$N" + "1" )); U=$(( "$U" + "$A" )); C=$(( "$C" + "$B" ))
	fi
done

echo ""
echo "----------------------------------"
echo "COMPLETED"
echo "Total # of tarballs created: $(human_readable $N)"
echo "Total size before compression: $(human_readable $U)"
echo "Total size after compression: $(human_readable $C)"

