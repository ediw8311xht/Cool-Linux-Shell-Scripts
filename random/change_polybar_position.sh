#!/bin/bash

LOCATION="$HOME/.config/polybar/config"

function left_right() {
    case "${1}" in 
        left)   sed -i             's/^\([ \t]*\)offset[-]x/;\1offset-x/' "${LOCATION}"
    ;; right)   sed -i 's/^\([ \t]*\);\([ \t]*\)offset[-]x/\1\2offset-x/' "${LOCATION}"
    ;;     *)   return 1
    ;;  esac
    return $?
}

function up_down() {
    case "${1}" in 
         up)    sed -i 's/^[ \t]*bottom[ \t]*[=][ \t]*true/    bottom = false/' "${LOCATION}"  
    ;; down)    sed -i 's/^[ \t]*bottom[ \t]*[=][ \t]*false/    bottom = true/' "${LOCATION}"
    ;;    *)    return 1 
    ;; esac
    return $?
}


function move_polyz() {
    CHECK="${1,,}"
    left_right "${CHECK}" || up_down "${_}" || {    
        echo "ERROR: INVALID ARGUMENT">&2
        return 1
    }
    return 0
}

move_polyz "$@"

