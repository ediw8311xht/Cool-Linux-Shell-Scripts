#!/bin/bash

save_bash_history() {
    local history_file="${HISTFILE:-"${HOME}/.bash_history"}"
    local save_file="bash_history_$(date +'%Y%m%d_%H%M%S').txt"
    if [[ -d "${BASH_HISTORY_ARCHIVE}" ]] ; then
        cp "${history_file}" "${BASH_HISTORY_ARCHIVE}/${save_file}"
    else
        cp "${history_file}" "${HOME}/${save_file}"
    fi
}

shut_g() {
    local count=0
    local max_iterations=10
    #save_bash_history
    trash-put "/tmp/tmplf.*"
    pkill arbtt
    while [[ "${count}" -lt "${max_iterations}" ]] && ps ax | grep -qPi 'd[e]luged' ; do
        killall 'deluged'
        sleep 1
    done
    i3-msg 'exit'
}

#save_bash_history
shut_g "${@}"
