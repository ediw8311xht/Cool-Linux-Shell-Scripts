#!/bin/bash


####################
( #-START-SUBSHELL-#
####################

INPUT_FILE="input.txt"
OUT_DIR="OUT_DIR_$(date +%s)/"
COOKIES="cookies.txt"
REDIRECTS='0'
USING="curl"

CURL_ARGS=(
      --max-redirs "${REDIRECTS}"
      --remote-header-name
      --remote-name
      --location
)

YT_DLP_ARGS=(
    -o "%(title)s.%(ext)s"
    --restrict-filename
)

with_wget() {
    echo "NOT IMPLEMENTED"; exit 1
}

with_curl() {
    if [[ -f "${COOKIES}" ]] ; then
        CURL_ARGS+=( --cookie "${COOKIES}" )
    fi
    curl "${CURL_ARGS[@]}" "${1}"
}


with_ytdl() {
    if [[ -f "${COOKIES}" ]] ; then
        YT_DLP_ARGS+=( --cookies "${COOKIES}" )
    fi
    yt-dlp  "${CURL_ARGS[@]}" "${1}"
}

getter() {
    if [[ ! -f "${INPUT_FILE}" ]] ; then
        echo "input file doesn't exist"; exit 1
    elif ! mkdir -p "${OUT_DIR}" || [[ ! -d "${OUT_DIR}" ]] ; then
        echo "issue creating output directory"; exit 1
    fi

    cd "${OUT_DIR}" || { echo "Issue cd'ing into OUT_DIR: '${OUT_DIR}'; Exiting..."; exit 1; }
    while read -r -d $'\n' i ; do
        if [[ "${USING}" = "ytdl" ]] && command -v "yt-dlp"; then
            with_ytdl "${i}"
        elif [[ "${USING}" = "wget" ]] && command -v "wget"; then
            with_wget "${i}"
        elif [[ "${USING}" = "curl" ]] && command -v "curl"; then
            with_curl "${i}"
        else
            echo "valid command not found"; exit 1
        fi
    done < "${INPUT_FILE}"
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
        " -i (default input.txt):"
        "       INPUT_FILE"
        " -o (default OUT_DIR_date_in_seconds):"
        "       OUT_DIR"
        " -c (default cookies.txt [When option provided]):"
        "       COOKIE_FILE"
        " -r (default 1 [number of redirects to follow, -1 for infinite]):"
        "       # of redirects"
        " -y (default false [use yt-dlp to download file instead of curl]):"
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
       -h|--help) help_function  ;  exit 0
    ;; -i)     INPUT_FILE="${2}" ; shift 2
    ;; -o)        OUT_DIR="${2}" ; shift 2
    ;; -r)      REDIRECTS="${2}" ; shift 2
    ;; -y)          USING="ytdl" ; shift 1
    ;; -w)          USING="wget" ; shift 1
    ;; -c)   if [[ -f "${2}" ]]  ; then COOKIES="${2}"        ; shift 2
             else                       COOKIES="cookies.txt" ; shift 1; fi
    ;; -*)   echo "Unrecognized Option/Flag"; exit 1
    ;;  *)   return
    ;; esac
    handle_args "${@}"
}


main() {
    handle_args "${@}"
    getter "${@}"
}

main "${@}"

####################
) #---END-SUBSHELL-#
####################
