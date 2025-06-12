#!/usr/bin/env bash


main() {
    # local DM_SETTINGS=()
    # read -r -d '' DM_SETTINGS < <(tr '\n' ' ' <<EOF
    # mapfile -d $'\n ' DM_SETTINGS < <(tr '\n' ' ' <<EOF
    local DM_SETTINGS="${HOME}/.dmenurc"
    # shellcheck source=/dev/null
    source "${DM_SETTINGS}"
    # provides DMENU_OPTIONS && DMENU_OPTIONS_G
	local DMENU_COMMAND='dmenu'
	local PROMPT=">"
    local i=0
    #local R_STDIN
    while [[ "${#}" -gt 0 ]] ; do
		case "${1,,}" in
                 -run) j4-dmenu-desktop --dmenu="dmenu -p '${PROMPT}' ${DMENU_OPTIONS_G}"; return
        ;;   -run-def) DMENU_COMMAND="dmenu_run" ; shift 1
        ;;  -p|-prompt) PROMPT="${2}"; shift 2
        #;;  -i|--stdin) read -r -p -t 5 R_STDIN; shift 1
        #;;  *) R_STDIN="${*}"; break
        ;;  *) break
		;;  esac
    done
        #-e 's|\(.*\)[/]\(.*\)|printf "%-80s    %s" "\2" "\1"|e' \
        #shellcheck disable=SC2046,SC2086

        # xargs -a <(echo "${DMENU_OPTIONS}") \
        timeout -k 10 10 "${DMENU_COMMAND}" -p "${PROMPT}" ${DMENU_OPTIONS} \
            < <( sed -e "s|$HOME|~|" /dev/stdin) \
            | sed "s|\~|$HOME|"
    # export -f run_this_script
    # timeout -k 3 3 bash -c run_this_script
    # unset -f run_this_script
    # run_this_script
}

main "${@}"

