#!/bin/bash

if [[ "$USER" != "root" ]] ; then echo "ERROR: PROGRAM REQUIRES SUDO"; exit 1; fi

#----------------------------------------------------------MODIFYING-PORT-NUMBER---#
#Mimics deluge random incoming-port number by manually setting it in config
deconf="/home/${SUDO_USER}/.config/deluge/core.conf" 
port="$(shuf -i "49152-65525" --head-count="1" )" 

if [[ "$#" -gt 0 ]] && [[ -f "$1" ]] ; then deconf="$1"; fi
if [[ "$#" -gt 1 ]] && [[ -n "$2" ]] ; then port="$2"; 	 fi

sline="$(grep -no "listen_ports" "${deconf}" | grep -Po "[0-9][0-9]+")"
echo ""; echo "|------------------STARTING PROGRAM------------------|"
echo "DELUGE CONFIG FILE TO WRITE TO: ${deconf}";						   sleep 1.0
echo "PORT # TO SET AS LISTEN: ${port}"; echo "";	   				       sleep 1.0

echo 		  "|-----------------CONFIRM LINES TO REPLACE-----------|";     sleep 1.0
sed -n "${sline},$((${sline} + 3))p" "${deconf}"
a="";read -p "|-----------(y/n)? " a; if [[ "${a:0:1}" =~ [N|n] ]] ; then exit 1; fi

#-------------------------------------------------------------MODIFY-CONFIG-FILE---#
sed -i "$(($sline + 1))s/.*/\t${port},/" "${deconf}"
sed -i "$(($sline + 2))s/.*/\t${port}/" "${deconf}"

echo $'\n'; echo "|------------UPDATED LINES-------------|";			   sleep 1.0
echo "$(sed -n "$sline,$(("$sline" + "3"))p" "${deconf}")";			       sleep 0.5
echo "|--------------------------------------|"; echo ""
#--------------------------------------------------------------------SETTING-UFW---#
ufw reset; 															       sleep 0.5
ufw default deny incoming;											       sleep 0.2
ufw default allow outgoing;											       sleep 0.2
ufw allow in "$port";												       sleep 0.2
#------------------------add/ delete as needed, defaults to allow alot of things---#
ufw allow in "DNS";													       sleep 0.2
ufw allow in "WWW"; ufw allow in "WWW Secure";							   sleep 0.2
ufw allow in "9050";												       sleep 0.2
ufw allow in "SSH";													       sleep 1.0
ufw enable


