#!/bin/bash


function handle_args() {

    case "${1,,}" in 
           -title) TITLE="${2}" ;;
           -theme) THEME="${2}" ;;
           -*);;*) TEXT="${@}"  ;return "$?"
    esac

    shift 2; handle_args "${@}"
}

function yad_hd() {
    TITLE="No Title Provided"
    TEXT="No Text Provided"

    handle_args "${@}"
    GTK_THEME="${THEME}"\
        yad --title "${TITLE}" --posx="${YAD_POS_X:-"1"}" --posy="${YAD_POS_Y:-"1"}" --height="1" --no-focus --no-buttons --text "${TEXT}" 
}

yad_hd "${@}"

