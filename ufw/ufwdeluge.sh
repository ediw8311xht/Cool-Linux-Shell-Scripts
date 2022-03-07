#!/bin/bash

ufw reset
ufw default deny incoming
#deluge uses a bunch of random ports for outgoing
#you can change to just use one, but it will probably be slower
ufw default allow outgoing
#idk deluge randomizes port between these ranges at default, so I am too 
#then passing to deluge make sure to unset random port on deluge for incoming
#SUSER="$(sudo env | grep -Po "(?<=SUDO_USER=).*")"
USERHOME="/home/${SUDO_USER}"

port="$(shuf -i "49152-65525" --head-count="1" )"
if [[ "$#" -gt 0 ]] && [[ -n "$1" ]] ; then
	port="$1"
fi

ufw allow in "$port"; sleep 2

#--------lets find line numbers of core config where listen port is set-#
deconf="$USERHOME/.config/deluge/core.conf"
if [[ "$#" -gt 1 ]] && [[ -f "$2" ]] ; then deconf="$2"; fi

sline="$(grep -no "listen_ports" "${deconf}" | grep -Po "[0-9][0-9]+")"
echo $'\n'; sleep 0.5
echo "CONFIG FILE TO WRITE TO: ${deconf}"; sleep 1
echo "PORT # TO SET AS LISTEN: ${port}"; sleep 1

sl1="$(("$sline" + 1))"; sl2="$(("$sline" + 2))"
#--------make sure right lines, then change-----------------------------#

echo $'\n'; sleep 0.5
echo "---ARE THESE THE CORRECT LINES OF THE LISTEN PORTS---"; sleep 2
echo "$(sed -n "${sl1}p" "${deconf}")"; sleep 1
echo "$(sed -n "${sl2}p" "${deconf}")"; sleep 0.5

a=""; read -p "-----------(Y/n)-> " a

echo $'\n'; sleep 0.5

if [ "$a" != "Y" ] ; then
	echo "You indicated those were the incorrect lines, you will have to modify them manually";
	sleep 0.5
else
	sed -i "${sl1}s/.*/\t${port},/" "${deconf}"; sed -i "${sl2}s/.*/\t${port}/" "${deconf}"
	echo "---UPDATED LINES---"; sleep 2
	echo "$(sed -n "${sl1}p" "${deconf}")"; sleep 1
	echo "$(sed -n "${sl2}p" "${deconf}")"; sleep 0.5
fi
#-----------------------------------------------------------------------#
#--------add/ delete as needed, defaults to allow alot of things--------#
echo $'\n'; sleep 0.5
ufw allow in "DNS"
ufw allow in "WWW Secure"
ufw allow in "WWW"
ufw allow in "9050"
ufw allow in "SSH"; sleep 1

ufw enable
