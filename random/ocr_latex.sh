#!/usr/bin/bash

# shellcheck disable=SC2155
main() {

local SCRIPT_NAME="${0}"
local DIR="$CLONED/pix2textg"
local PIC_DIR="/tmp/screenshots/"
mkdir -p "${PIC_DIR}"
local PORT="8123"
local URL="http://0.0.0.0:${PORT}/pix2text"
local SERVER_LOG="/tmp/server_log_$(date +'%s').txt"
send_to_server() {
    local OPTS
    OPTS=(
      -F "file_type=${2:-formula}"
      -F "resized_shape=768"
      -F "embed_sep= $,$ "
      -F "isolated_sep=$$\n, \n$$"
      -F "image=@${1}"
    )

    [[ ! -f "${1}" ]] &&
        {   echo "File not found: '${1}'" >/dev/stderr; return 2; }
    curl -X POST "${OPTS[@]}" "${URL}" \
        | jq -r '.results' \
        | sed -e 's/\\\\/\\/g'
}

kill_server() {
    pkill p2t && return $?
}

run_server() {
    cd "${DIR}" || { echo "Error trying to to cd into '${DIR}'" >/dev/stderr; return 1; }
    nohup p2t serve -l en -H 0.0.0.0 -p "${PORT}" &>"${SERVER_LOG}" &
    notify-send "${SCRIPT_NAME}" "Server started"
}

screenshot_to_latex() {
    local LATEX
    local SCREENSHOT="${PIC_DIR}screenshot_$(date +'%s').jpeg"
    
    maim -s "${SCREENSHOT}"
    LATEX="$(send_to_server "${SCREENSHOT}" "${2}")"
    if [[ -z "${LATEX}" ]] ; then 
        notify-send "${SCRIPT_NAME}" "Error getting latex"
        return 1
    else
        notify-send "${SCRIPT_NAME}" "${LATEX}"
        xclip -selection clipbaord <<< "${LATEX}"
    fi

}

handle_args() {
    [[ "${#}" -le 0 ]] && return 0
    case "${1,,}" in 
       start|run) run_server
    ;;      kill) kill_server
    ;;      send) send_to_server "${2}" "${3}"; shift 1
    ;;      shot) screenshot_to_latex "${2}"; shift 1
    ;;         *) echo "Invalid command: '${1,,}'" >/dev/stderr; return 2
    esac
    shift 1
}

handle_args "${@}"

}

main "${@}"

