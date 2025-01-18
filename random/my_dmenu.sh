#!/usr/bin/env bash


main() {
    local DM_SETTINGS=""
    read -r -d '' DM_SETTINGS < <(tr '\n' ' ' <<EOF
-i
-l  '40'
-b
-x  '20'
-y  '20'
-w  '800'
-sb '#222222'
-sf '#00FF00'
-nf '#AAAAAA'
-nb '#000000'
-fn 'InputMono:style=Regular:pixelsize=12:antialias=true:autohint=true'
EOF
    )
	local dmenu_command='dmenu'
	local PROMPT=">"
    #local R_STDIN
    while [[ "${#}" -gt 0 ]] ; do
		case "${1,,}" in
            -run) j4-dmenu-desktop --dmenu="dmenu -p '${PROMPT}' ${DM_SETTINGS}"; return
        ;;  -p|-prompt) PROMPT="${2}"; shift 2
        #;;  -i|--stdin) read -r -p -t 5 R_STDIN; shift 1
        #;;  *) R_STDIN="${*}"; break
        ;;  *) break
		;;  esac
    done

    "${dmenu_command}" -p "${PROMPT}" $(tr "'" ' ' <<< "${DM_SETTINGS}")
}

main "${@}"
