#!/bin/bash


####################
( #-START-SUBSHELL-#
####################

INPUT_FILE="input.txt"
OUT_DIR="OUT_DIR_$(date +%s)/"
COOKIES="cookies.txt"
REDIRECTS='0'
USING="curl"
NO_OUTPUT=0

CURL_ARGS=(
      --max-redirs "${REDIRECTS}"
      --remote-header-name
      --remote-name
      --location
      --remove-on-error
)

YT_DLP_ARGS=(
    -o "%(title)s.%(ext)s"
    --restrict-filename
)

with_wget() {
    echo "NOT IMPLEMENTED"; exit 1
}

with_weasyprint() {
    weasyprint "${1}" "${2}.pdf"
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
    local count=1
    if [[ ! -f "${INPUT_FILE}" ]] ; then
        echo "input file doesn't exist"; exit 1
    elif ! mkdir -p "${OUT_DIR}" || [[ ! -d "${OUT_DIR}" ]] ; then
        echo "issue creating output directory"; exit 1
    fi

    cd "${OUT_DIR}" || { echo "Issue cd'ing into OUT_DIR: '${OUT_DIR}'; Exiting..."; exit 1; }
    while read -r -d $'\n' i ; do
        if [[ "${USING}" = "ytdl" ]] ; then
            with_ytdl "${i}"
        elif [[ "${USING}" = "wget" ]] ; then
            with_wget "${i}"
        elif [[ "${USING}" = "curl" ]] ; then
            with_curl "${i}"
        elif [[ "${USING}" = "weasyprint" ]] ; then
            with_weasyprint "${i}" "${count}"
        fi
        ((count++))
    done < "${INPUT_FILE}"
    echo "--------------------------"
    echo "${count} files downloaded."
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
        " -i (default 'input.txt'):"
        "       INPUT_FILE"
        " -o (default 'OUT_DIR_[Date in seconds]'):"
        "       OUT_DIR"
        " -c (default 'cookies.txt' [When option provided]):"
        "       COOKIE_FILE"
        " -r (default '1' [number of redirects to follow, '-1' for infinite]):"
        "       # of redirects"
        " -y  (default false [use yt-dlp to download file instead of curl]):"
        " -w  (default false [use wget to download file instead of curl]):"
        " -wp (default false [use weasyprint to download file as pdf]):"
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
       -h|--help) help_function        ;  exit 0
    ;; -i)     INPUT_FILE="${2}"       ; shift 2
    ;; -o)        OUT_DIR="${2}"       ; shift 2
    ;; -r)      REDIRECTS="${2}"       ; shift 2
    ;; -y)          USING="ytdl"       ; shift 1
    ;; -w)          USING="wget"       ; shift 1
    ;; -wp)         USING="weasyprint" ; shift 1
    ;; -no)     NO_OUTPUT=1            ; shift 1
    ;; -c)   if [[ -f "${2}" ]]  ; then COOKIES="${2}"        ; shift 2
             else                       COOKIES="cookies.txt" ; shift 1; fi
    ;; -*)   echo "Unrecognized Option/Flag"; exit 1
    ;;  *)   return
    ;; esac
    handle_args "${@}"
}


main() {
    handle_args "${@}"
    if ! command -v "${USING}" ; then
        echo "Command: '${USING}' couldn't be found" >&2; exit 1
    fi
    INPUT_FILE="$(readlink -f "${INPUT_FILE}")"
    getter "${@}"
}

main "${@}"

####################
) #---END-SUBSHELL-#
####################
