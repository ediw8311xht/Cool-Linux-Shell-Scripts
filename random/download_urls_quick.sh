#!/bin/bash


####################
( #-START-SUBSHELL-#
####################

TXT_DOT_URLS="input.txt"
OUTPUT_DIR="OUTPUT_DIR_$(date +%s)/"
COOKIE_FILE=""
REDIRECTS='0'

with_cookies() {
    curl    --cookie     "${COOKIE_FILE}"       \
            --max-redirs "${REDIRECTS}"         \
            --location   "${1}"                 \
            --remote-header-name                \
            --remote-name                       \
            --output-dir "${OUTPUT_DIR}"
            #> "${OUTPUT_DIR}/${1//[\/:]/_}"
}

no_cookies() {
    curl    --max-redirs "${REDIRECTS}"         \
            --location   "${1}"                 \
            --remote-header-name                \
            --remote-name                       \
            --output-dir "${OUTPUT_DIR}"
}

getter() {
    echo "${TXT_DOT_URLS}"
    echo "${COOKIE_FILE}"
    echo "${OUTPUT_DIR}"
    { [[ ! -f "${TXT_DOT_URLS}" ]]                                ; } ||
    { [[ "${COOKIE_FILE}" != "" ]] && [[ ! -f "${COOKIE_FILE}" ]] ; } ||
    { ! mkdir "${OUTPUT_DIR}"                                     ; } &&
    {
        echo "Doesn't exist"
        return 1
    }

    while read -r -d $'\n' i ; do
        if [[ -f "${COOKIE_FILE}" ]] ; then
            with_cookies "${i}"
        else
            no_cookies "${i}"
        fi
    done < "${TXT_DOT_URLS}"
}

max_length() {
    local MAX='-1'
    for i in "${@}" ; do
        [[ "${#i}" -gt "${MAX}" ]] && MAX="${#i}"
    done
    echo "${MAX}"
}

help_function() {
    local MAX_LENGTH
    local PADDING="5"
    local a=(
        " -i, --input, -f, --file (default input.txt):"
        "       TXT_DOT_URLS"
        " -o, -d, --dir, --output (default OUTPUT_DIR_date_in_seconds):"
        "       OUTPUT_DIR"
        " -c, --cookies           (default cookies.txt [When option provided]):"
        "       COOKIE_FILE"
        " -r, --redirects         (default 1 [number of redirects to follow, -1 for infinite]):"
        "       # of redirects"
    )

    ((MAX_LENGTH=$(max_length "${a[@]}") + PADDING))

    echo ""
    printf " %${MAX_LENGTH}s " | tr ' ' '_' ; echo
    printf "|%-${MAX_LENGTH}s|\n" " ${0##*/}"
    printf "|%${MAX_LENGTH}s|" | tr ' ' '_' ; echo
    for i in "${a[@]}" ; do
        printf "|%-${MAX_LENGTH}s|\n" "$(echo -e "${i}")"
    done
    printf "|%${MAX_LENGTH}s|" | tr ' ' '-' ; echo
    echo ""
}

handle_args() {
    case "${1,,}" in
        --help) help_function; exit 0
    ;;  -i|--input|-f|--file) TXT_DOT_URLS="${2}"
    ;;  -o|-d|--dir|--output) OUTPUT_DIR="${2}"
    ;;          -c|--cookies) COOKIE_FILE="${2:-"cookies.txt"}"
    ;;        -r|--redirects)   REDIRECTS="${2:-"cookies.txt"}"
    ;;                    -*) echo "Unrecognized Option/Flag"
    ;;                     *) return
    ;; esac
    shift 2; handle_args "${@}"
}


main() {
    handle_args "${@}"
    getter "${@}"
}

main "${@}"

####################
) #---END-SUBSHELL-#
####################
