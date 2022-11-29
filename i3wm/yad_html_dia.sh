#!/bin/bash


function yad_hd() {
    yad --title "${1:-"No Title Provided"}" --posx="1" --posy="1" --height="1" --no-focus --no-buttons --text "${2:-"${1}"}" 
}


yad_hd "${@}"

