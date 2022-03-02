#!/bin/bash

isint() { if [[ $1 =~ ^([\-]?[1-9][0-9]?+|0)$ ]] ; then echo "yes"; else echo "no"; fi }
isposint() { if [[ $1 =~ ^([1-9][0-9]?+|0)$ ]] ; then echo "yes"; else echo "no"; fi }

DATA_FILE="$HOME/bin/Data/nitroDATA.txt"

WF_DATA=($(sed -n 1p "${DATA_FILE}"))
PIC_PATH=$(sed -n 2p "${DATA_FILE}")
#LF_DIR=$(sed -n 3p "${DATA_FILE}")

DIRECTION=$1

if [[ $DIRECTION == "UP" ]] ; then 
	WF_DATA=$(( $WF_DATA + 1 ))
elif [[ $DIRECTION == "DOWN" ]] ; then
	WF_DATA=$(( $WF_DATA - 1 ))
elif [[ $DIRECTION == "RIGHT" ]] ; then
	WF_DATA=$(( $WF_DATA + 2 ))
elif [[ $DIRECTION == "LEFT" ]] ; then
	WF_DATA=$(( $WF_DATA - 2 ))
fi

echo "READ FROM FILE: ${WF_DATA}"

if [[ $(isposint "${WF_DATA}") == "yes" ]] ; then 
	echo "SUCCESS: IS A POSITIVE NUMBER"; 
else 
	echo "ERROR: IS NOT A POSITIVE NUMBER"; exit 1; 
fi

# if [[ -n $2 ]] ; then PIC_PATH=$2; WF_DATA=0; else PIC_PATH=$(sed -n 2p "${DATA_FILE}"); fi
if [[ -n $2 ]] ; then
	PIC_PATH=$2
	WF_DATA=0
fi

echo "${PIC_PATH}"

if ! [ -d $PIC_PATH ] ; then
	echo "ERROR 1st Argument: DIRRECTORY ARGUMENT"
	echo "EITHER NOT DIRECTORY OR NOT PASSED"
	exit 1
fi

#GETTING PICTURES PATH IN DIR > DIRECTORY

# ALL_F=$(ls -L -1 $PIC_PATH | grep -P "(.*\.png|.*\.jpg)")
ALL_F=$(ls -Lt -1 "${PIC_PATH}"*.png "${PIC_PATH}"*.jpg)
NUM_F=$(echo "${ALL_F[@]}" | wc -l)
#WF_DATA=$(( $WF_DATA % $NUM_F ))
ALL_F=($ALL_F)

if [[ NUM_F -lt 1 ]] ; then echo "ERROR .png or .jpg NOT FOUND in DIRECTORY GIVEN"; exit 1; fi

if [[ $WF_DATA -ge $NUM_F ]] ; then
	WF_DATA=$(( $NUM_F - 1 ))
elif [[ $WF_DATA -lt 0 ]] ; then
	WF_DATA=0
fi

echo "WF: ${WF_DATA}"
echo "current file: ${ALL_F[${WF_DATA}]}"
echo "WRITING TO SAVE FILE"
echo "${WF_DATA}" > "${DATA_FILE}"
echo "${PIC_PATH}" >> "${DATA_FILE}"

echo $(nitrogen --head=0 --save --set-auto "${ALL_F[${WF_DATA}]}")
echo $(nitrogen --head=1 --save --set-auto "${ALL_F[${WF_DATA}]}")



