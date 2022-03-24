#!/bin/bash

#tree -ifpugDsh "${1:-/}" | grep -Po "${2:^[0-9]+G

if [[ -n "${2}" ]] ; then
	OLDIFS="${IFS}"; IFS=$'\n'
	DECI="(\.[0-9]+)?"
	ODIG="[0-9]+${DECI}"
	RDIG="[0-9]{${2:0:-1}}[0-9]*${DECI}"
	if [[ "${2}" =~ T ]] ; then
		BONE="${RDIG}T"
	elif [[ "${2}" =~ G ]] ; then
		BONE="(${RDIG}G|${ODIG}T)"
	elif [[ "${2}" =~ M ]] ; then
		BONE="(${RDIG}M|${ODIG}[T|G])"
	elif [[ "${2}" =~ K ]] ; then
		BONE="(${RDIG}K|${ODIG}[T|G|M])"
	else
		echo "MUST BE \"T or G or M or K \" "
		exit 1
	fi
	
	echo "${BONE}"
	#exit 0
	tree -ifpugDsh "${1:-/}" | grep -P "\ ${BONE}\ (?=[A-Z][a-z][a-z]\ .{8}\])"
	IFS="${OLDIFS}"
else
	tree -ifpugDsh "${1:-/}" | grep -P "\ [0-9]+(\.[0-9]+)?G\ (?=[A-Z][a-z][a-z]\ .{8}\])"
fi

