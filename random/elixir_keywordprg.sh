#!/bin/bash

get_info() {
    if   [[ "${1}" = '-h' ]] ; then
        elixir --erl "-elixir ansi enabled true" -e "require(IEx.Helpers); IEx.Helpers.h(${2})"
    elif [[ "${1}" = '-b' ]] ; then
        elixir --erl "-elixir ansi enabled true" -e "require(IEx.Helpers); IEx.Helpers.b(${2})"
    fi
}

color_and_display() {
    perl -0777 -p \
        -e 's/^/\e[40m/;' \
        -e 's/`([^`]*)`/\e[32m\1\e[37m/g;' \
        -e 's/\n(([ ]{4,8}|[\t]+)[^\n]+)/\n\e[32m\1\e[37m/g;' \
        -e 's/\n[#]{1,5}([^\n]*)/\n\e[07m\1\e[27m/g;' \
        <<< "${1}" \
        | bat --style numbers,rule
}

main() {
    local output_from
    output_from="$(get_info -h "${1}")"
    if [[ "${output_from}" =~ ^No\ documentation\ for.*$ ]] ; then
        output_from="$(get_info -b "${1}")"
    fi
    color_and_display "${output_from}"
}

main "${@}"
