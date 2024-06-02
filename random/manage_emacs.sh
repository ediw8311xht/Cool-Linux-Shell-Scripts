#!/bin/bash


help_func() {
    local DESCRIPTION="Manage Emacs Daemon"
    local OPTIONS='''
------------------------------------------------
    -h: print help for this program
    -s: start emacs daemon
    -r: restart emacs daemon at env var EMACS_SOCKET_NAME
    -k: kill emacs daemon
    -n: open emacs client [OPTIONAL (file name)]
    -d: run doom sync, and restart emacs daemon
------------------------------------------------
    '''
    printf "%s\n" '' "${DESCRIPTION}" "${OPTIONS}"
}

start_emacs_daemon() {
    emacs --daemon
    #="${EMACS_SOCKET_NAME}"
    xmessage -timeout 4 "emacs started" & disown
}

kill_emacs_daemon() {
    emacsclient -e "(kill-emacs)"
}

open_emacs_client() {
    emacsclient --reuse-frame --no-wait "${@}"
}

restart_emacs_daemon() {
    kill_emacs_daemon
    sleep 0.5
    start_emacs_daemon
}

doom_sync_restart() {
    doom sync
    restart_emacs_daemon
}

manage_emacs_daemon() {
    if [[ "${1,,}" = '-s' ]] ; then
        start_emacs_daemon
    elif [[ "${1,,}" = '-r' ]] ; then
        restart_emacs_daemon
    elif [[ "${1,,}" = '-k' ]] ; then
        kill_emacs_daemon
    elif [[ "${1,,}" = '-n' ]] ; then
        open_emacs_client "${@:2}"
    elif [[ "${1,,}" = '-d' ]] ; then
        doom_sync_restart
    else
        help_func
    fi
}

main() {
    manage_emacs_daemon "${@}"
}

main "${@}"


