#!/bin/bash

read_histfile() {
    sqlite3 "${1}" "SELECT file FROM fileinfo ORDER BY time" | tac;
}

main() {
    local data_dir="${XDG_DATA_HOME:-"${HOME}/.local/share"}"
    local hfile="${data_dir}/zathura/bookmarks.sqlite"
    if [[ ! -f "${hfile}" ]] ; then echo "zathura history file: '${hfile}'"; exit 1; fi
    while read -r -d $'\n' f ; do
        if [[ -f "${f}" ]] ; then
            zathura "${@}" "${f}" 2>"${HOME}/.cache/zathura_errors.txt"
            return "${?}"
        fi
    done < <(read_histfile "${hfile}")
}

main "${@}"


