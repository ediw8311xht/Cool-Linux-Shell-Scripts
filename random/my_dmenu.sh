#!/usr/bin/env bash


main() {
	local DM_SETTINGS=(
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
	)
	local dmenu_command='dmenu'
	local PROMPT=">"
    while [[ "${#}" -gt 0 ]] ; do
		case "${1,,}" in
			     -run) dmenu_command='dmenu_run'; shift 1
        ;; -p|-prompt) PROMPT="${2}"; shift 2
        ;; *) break
		;; esac
    done

	"${dmenu_command}" -p "${PROMPT}" "${DM_SETTINGS[@]}" < "${1:-/dev/stdin}"
}

main "${@}"
