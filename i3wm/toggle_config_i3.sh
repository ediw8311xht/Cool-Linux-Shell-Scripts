#!/bin/bash


(

set -eu

print_type() {
    if [[ -d "${1}" ]] ; then
        printf 'd'
    elif [[ -f "${1}" ]] ; then
        printf 'f'
    else
        return 1
    fi
}

swap_configs() {
    local HOLD_SWAP

    if [[ "$(print_type "${1}")" != "$(print_type "${2}")" ]] ; then
        return 1
    fi

    # Using `readlink -f` to ensure directory exists and to remove `/` from end of variable name if it exists.
    HOLD_SWAP="$(readlink -f "${1}")_$(date +%s)"

    mv --no-clobber --no-copy --no-target-directory "${1}"          "${HOLD_SWAP}"
    mv --no-clobber --no-copy --no-target-directory "${2}"          "${1}"
    mv --no-clobber --no-copy --no-target-directory "${HOLD_SWAP}"  "${2}"
}

main() {
    swap_configs "${I3_CONFIG}" "${I3_CONFIG_SWAP}" && echo $?
    i3 -C "${HOME}/.config/i3/config/"
    i3-msg 	"reload; restart"
}


main "${@}"

)
