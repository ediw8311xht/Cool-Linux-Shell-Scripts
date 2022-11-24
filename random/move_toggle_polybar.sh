#!/bin/bash

CONFIG_INI="$HOME/.config/polybar/config.ini"
LAUNCH_POLYBAR="$HOME/.config/polybar/launch.sh"

function left_right() {
    case "${1}" in 
         left)  sed -i             's/^\([ \t]*\)offset[-]x/;\1offset-x/' "${CONFIG_INI}"
    ;;  right)  sed -i 's/^\([ \t]*\);\([ \t]*\)offset[-]x/\1\2offset-x/' "${CONFIG_INI}"
    ;;      *)  return 1
    ;;  esac
    return $?
}

function up_down() {
    case "${1}" in 
           up)   sed -i 's/^[ \t]*bottom[ \t]*[=][ \t]*true/    bottom = false/' "${CONFIG_INI}"  
    ;;   down)   sed -i 's/^[ \t]*bottom[ \t]*[=][ \t]*false/    bottom = true/' "${CONFIG_INI}"
    ;;      *)   return 1 
    ;; esac
    return $?
}

function hide_show() {
    case "${1}" in 
         hide)  killall polybar
    ;;   show)  "${LAUNCH_POLYBAR}"
    ;; toggle)  hide_show "hide" || hide_show "show"
    ;;     *)   return 1 
    ;; esac
    return $?
}


function move_polyz() {
    CHECK="${1,,}"
    left_right "${CHECK}" || up_down "${_}" || hide_show "${_}" || {    
        echo "ERROR: INVALID ARGUMENT">&2
        return 1
    }
    return 0
}

move_polyz "$@"

