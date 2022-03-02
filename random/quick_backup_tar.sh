#!/bin/bash

DEFAULT=$HOME/bin/Data/files_to_backup.txt
LTE=($(cat "${DEFAULT}"))

human_readable() {
	echo $(echo "$1" | numfmt --to=iec)
}

get_size() {
	echo "$(du -s $1 | grep -Po '^[1-9][0-9]*')"
}

mtar_back() {
	if [[ -n "$1" ]] ; then 
		if [[ -f "$2" ]] || [[ -d "$2" ]] ; then
			echo $(tar --exclude-caches -czvf "${1}" "${2}")
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

if [[ -n $1 ]] ; then
	LTE=($@)
fi

echo "FILES TO COMPRESS:"
echo "${LTE[@]}"

N=0; U=0; C=0

for pte in ${LTE[@]} ; do
	echo ""
	if [[ "$pte" =~ ^\#.* ]] ; then
		echo 	 "####SKIPPED FILE/DIR ( $pte ); COMMENTED OUT"
	else
		dt=$(date '+BACKUP_%Y_%m_%d_%H%M__')
		noslash="${pte//\//\-}"
		tarfile="$HOME/BACKUP_FILES/AUTO_BACKUP/${dt}${noslash}.tar.gz"
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

