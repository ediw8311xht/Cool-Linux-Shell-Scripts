#!/bin/bash

D1=${1:-"/mnt/od/UPLOADED"}
D2=${2:-"/mnt/ad/LNB/BACKUP"}
REG=${3:-"^.*(?<!torrent)$"}

IFS=$'\n'
L1=$(ls -1 "${D1}" | grep -Pi '^.*(?<!\.torrent)$')
L2=$(ls -1 "${D2}" | grep -Pi '^.*(?<!\.torrent)$')

F1=$(mktemp); F2=$(mktemp)
echo "${L1}" > "${F1}"
echo "${L2}" > "${F2}"

sort "${F1}" -o "${F1}"
sort "${F2}" -o "${F2}"


#cat "${F2}"
#exit 0
LEN1=($(cat "${F1}")); LEN2=($(cat "${F2}"))
#cat "${F2}"
ZEN1=("$(comm -3 "${F1}" "${F2}")"); ZEN2=("$(comm -13 "${F1}" "${F2}")")
echo "${ZEN1[@]}"
echo "${#ZEN1[@]}"
echo "${#ZEN2[@]}"
echo "${#LEN1[@]}"
echo "${#LEN2[@]}"
