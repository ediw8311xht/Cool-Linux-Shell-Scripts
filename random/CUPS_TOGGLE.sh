#!/bin/bash


if [[ "$USER" != "root" ]] ; then echo "MUST RUN PROGRAM USING SUDO"; sleep 1; exit 1; fi

G="$(ufw status verbose)"

A="$(echo "${G}" | grep -Pi "192\.168\.1\.0/24.+DENY.+Anywhere")"
B="$(echo "${G}" | grep -Pi "Anywhere.+DENY.+192\.168\.1\.0/24")"


if [[ -n "$A" ]] || [[ -n "$B" ]] ; then
	ufw disable 
	ufw allow to 	192.168.1.0/24
	ufw allow from 	192.168.1.0/24
	ufw enable
	systemctl start cups
	cupsenable "$MYPRINTER"
	echo ""
	echo "ENABLED"
else 
	ufw disable
	ufw deny to 	192.168.1.0/24
	ufw deny from 	192.168.1.0/24
	ufw enable
	systemctl stop cups
	cupsdisable "$MYPRINTER"
	echo ""
	echo "DISABLED"
fi

