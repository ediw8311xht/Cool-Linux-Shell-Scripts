#!/bin/bash

#RULE_FILE2="/mnt/ad/LNB/rule_file2.txt"
DEFAULT_OUT="/mnt/ad/DEFAULT_BACKUP"
DEFAULT_IN="/mnt/ad/LNB/BACKUP"
RULE_FILE="${1:-../Data/mover_sh_rule.txt}"
DATA_FILE="${2:-../Data/mover_sh_data.txt}"

xr() { tput setaf 1; }; xg() { tput setaf 2; }; xy() { tput setaf 3; }; xb() { tput setaf 45; }; xw() { tput setaf 7; }
xp() { tput setaf 200; }; xo() { tput setaf 208; }; xl() { tput setaf 13; }

rename_file() { echo "${BASE}" | sed "s/ /_/g" | sed "s/\./_/g" | sed "s/-/_/g" | sed "s/,/_/g";  }

# DIR_IN, FILE_TO_COPY, DIR_OUT
convert_copy_file() {
	BASE="${2%.*}"; EXT="${2##*.}"; REN=$(rename_file "${BASE}"); F_NEW=""
	JELLO="${1}/${2}"

	if [[ "${EXT}" = "webp" ]] ; then
		F_NEW="${3}/${REN}.png";   if [[ -f "${F_NEW}" ]] || [[ -d "${F_NEW}" ]] ; then echo "FILE/DIRECTORY:  ${F_NEW} ALREADY EXISTS"; exit 1; fi
		dwebp "${JELLO}" -o "${F_NEW}"
	else
		F_NEW="${3}/${REN}.${EXT}"; if [[ -f "${F_NEW}" ]] || [[ -d "${F_NEW}" ]] ; then echo "FILE/DIRECTORY:  ${F_NEW} ALREADY EXISTS"; exit 1; fi
		cp -rvn "${JELLO}" "${F_NEW}"
	fi
	
	if [[ ! -f "${F_NEW}" ]] && [[ ! -d "${F_NEW}" ]] ; then 
		xr; echo "COPYING FILE FAILED" ; return 1
	else	
		xg; echo "COPYING FILE SUCCESS"; return 0
	fi
}

if   [[ ! -f "${RULE_FILE}" ]] ; then   xr; echo "RULE FILE NOT FOUND"; exit 1; fi
if   [[ ! -f "${DATA_FILE}" ]] ; then   xr; echo "DATA FILE NOT FOUND"; exit 1; fi

IFS=$'\n'; RULES=($(cat "${RULE_FILE}"))

for RULE in "${RULES[@]}" ; do
	xy; IFS=$' \t\n'; L=(${RULE})
	
	# RULE FILE CAN PROVIDE INPUT AND OUTPUT DIRECTORY OR USE DEFAULT_IN / DEFAULT_OUT
	DIR_I="${L[1]:-${DEFAULT_IN}}"; DIR_O="${L[2]:-${DEFAULT_OUT}}"

	# Add "#" in front of rule (line in text file) to skip it
	if 	 [[ "${L[0]}" =~ ^\# ]] ; then echo 		"RULE: ${L[@]} SKIPPED";	continue; fi
	
	# VALIDATING RULE & DIR_O/DIR_I, SKIPS IF INVALID
	if   [[ ! -d "${DIR_O}"  ]] ; then xr; echo "ERROR, ${DIR_O} DOESN'T EXIST";	continue
	elif [[ ! -d "${DIR_I}"  ]] ; then xr; echo "ERROR, ${DIR_I} DOESN'T EXIST";	continue
	elif [[ -z "${L[@]}"         ]] || [[ "${#L[@]}" -gt 3    ]]   || 
		 [[ "${DIR_I: -1}" = "/" ]] || [[ "${DIR_O: -1}" = "/" ]] ; then
		xr; echo "ERROR IN RULE: ${RULE}"; 											continue
	fi

	# GET FILES IN DIR_I, AND SAVE TO TEMP FILE
	IFS=$'\n'
	MYTEMP=$(mktemp); ls -d1 "${DIR_I}/"* | grep -Pi "${L[0]}" > "${MYTEMP}"
	cat "${MYTEMP}"

	# MUST SORT FILES BEFORE USING "comm"
	sort "${MYTEMP}" -o "${MYTEMP}"; sort "${DATA_FILE}" -o "${DATA_FILE}"

	# FILTER FILES ALREADY INSIDE "DATA_FILE"
	J=("$(comm -23 "${MYTEMP}" "${DATA_FILE}")")

	xb; echo "|------- FILES/DIRS TO COPY: ----------|"
	xl; echo "${J[*]}"
	xb; echo "|--------------------------------------|"
	A="_"; read -p "Continue? (y|N) > " A; if [[ ! "${A}" =~ (Y|y|Yes|yes|YES) ]] ; then echo "SKIPPING"; sleep 1; continue; fi

	xg; echo "---------------------START-RULE--------------------------------------"
	for key in ${J[@]} ; do 
		#echo "${key}"
		FILE_NO_PATH="${key##*\/}"
		convert_copy_file  "${DIR_I}" "${FILE_NO_PATH}" "${DIR_O}"
		if [[ "$?" = 0 ]] ; then 
			echo "${key}" >> "${DATA_FILE}"
			COUNT=$(( "${COUNT}" + 1 ))
		else 
			echo "THERE WAS AN ISSUE COPYING FILE ${key}"
		fi
	done
	xg; echo "---------------------END-RULE--------------------------------------"
done

