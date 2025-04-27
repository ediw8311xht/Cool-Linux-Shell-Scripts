#!/bin/bash

get_full_path() {
    echo
}

check_files() {
    if [[ "${#}" -le 0 ]] ; then
        return 0
    elif [[ ! -f "${1}" ]] ; then 
        printf "File Not Found: '%s'\n" "${1}" >&2
        exit 1
    else
        check_files "${@: 2}"
    fi
}

main() {
    local outfile="/tmp/cpp_tmp.out"
    local exit_code
    local run_file=""
    local info_file="./.my_info"

    if [[ "${1##*.}" = "my_info" ]] ; then
        info_file="${1}"; shift 1
    fi
    if [[ -n "${1}" ]] && check_files "${@}" ; then
        run_file="${*}"
    elif ! run_file="$(fd -e .cpp -e .h)" ; then
        echo "No .cpp/.h files found" >&2
        return 1;
    fi

    if [[ -f "${info_file}" ]] ; then
        xargs g++ -std="c++20" @"${info_file}" -o "${outfile}" <<< "${run_file}"
    else
        xargs g++ -std="c++20" @"${info_file}" -o "${outfile}" <<< "${run_file}"
    fi


    exit_code="$?"

    if [[ "${exit_code}" -eq 0 ]] &&  [[ -f "${outfile}" ]] ; then
        "${outfile}"
    fi
}

main "${@}"
