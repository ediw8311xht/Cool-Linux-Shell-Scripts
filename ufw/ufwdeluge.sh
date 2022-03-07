#!/bin/bash

ufw reset
ufw default deny incoming
ufw default allow outgoing

#--------------------------------MODIFYING-PORT-NUMBER--------------------------------------------------------#
USERHOME="/home/${SUDO_USER}"
deconf="$USERHOME/.config/deluge/core.conf"; if [[ "$#" -gt 0 ]] && [[ -f "$1" ]] ; then deconf="$1"; fi
sline="$(grep -no "listen_ports" "${deconf}" | grep -Po "[0-9][0-9]+")"
#deluge randomizes port between these ranges at default, this program mimics that
#so you can have random port and only enable that one port for listening in firewall
port="$(shuf -i "49152-65525" --head-count="1" )" ; if [[ "$#" -gt 1 ]] && [[ -n "$2" ]] ; then port="$2"; fi

ufw allow in "$port"; sleep 1

echo $'\n'; sleep 0.5
echo "CONFIG FILE TO WRITE TO: ${deconf}"; sleep 1
echo "PORT # TO SET AS LISTEN: ${port}"; sleep 1

echo $'\n'; sleep 0.5
echo "---ARE THESE LINES CORRECT TO REPLACE WITH NEW LISTEN PORT?---"; sleep 1
sed -n "${sline},$((${sline} + 3))p" "${deconf}"; sleep 0.5
a=""; read -p "-----------(Y/n)-> " a

echo $'\n'; sleep 0.5

if [[ "$a" = "Y" ]] || [[ "$a" = "y" ]] || [[ "$a"  = "yes" ]] || [[ "$a"  = "Yes" ]] || [[ -z "$a" ]];  then
	#-----------------MODIFY-CONFIG-LISTEN-PORTS---------------------#
	sed -i "$(($sline + 1))s/.*/\t${port},/" "${deconf}"
	sed -i "$(($sline + 2))s/.*/\t${port}/" "${deconf}"
	#-------------------------------------------------------------------#
	echo "---UPDATED LINES---"; sleep 1
	echo "$(sed -n "$sline,$(("$sline" + "3"))p" "${deconf}")"; sleep 0.5
else
	echo "You indicated those were the incorrect lines, you will have to modify them manually"; sleep 0.5
fi
#--------------------------------BACK-TO-MAIN-PROGRAM---------------------------------------------------------#

#--------add/ delete as needed, defaults to allow alot of things--------#
echo $'\n'; sleep 0.5
ufw allow in "DNS"
ufw allow in "WWW Secure"
ufw allow in "WWW"
ufw allow in "9050"
ufw allow in "SSH"; sleep 1

ufw enable
