#!/bin/bash

TIMES=2
BEFORE="3"
AFTER="1"

while [[ "${1}" =~ ^- ]] ; do
    case "${1}" in -[0-9]) 
        TIMES="${1/-/}"
        ;;
    -a[0-9]) 
        BEFORE="${1/-a/}" 
        ;;
    -b[0-9]) 
        AFTER="${1/-b/}" 
        ;;
    esac
    shift 1
done

BEFORE="$(while [[ $((BEFORE--)) -gt 0 ]] ; do echo -n "\t"; done)"
AFTER=" $(while [[ $((AFTER--)) -gt 0 ]] ; do echo -n "\t"; done)"
z="$(echo "${*}" | tr '\n' '|')"
z="$(perl -pe 's/(([^|]+\|){'"${TIMES}"'})/\1\n/g' <<< "${z}")"

perl -pe 's/(?<![ \t])\|(?![\t])/'"${AFTER}"'\|'"${BEFORE}"'/g' <<< "${z}"
