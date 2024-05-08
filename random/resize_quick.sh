#!/bin/bash

####################
( #-START-SUBSHELL-#
####################
X_LIM=3000
Y_LIM=3000
OVERWRITE=0
RESIZE=30
RANDOM_FOUR=""
DIR="${PWD}"

print_x() {
    printf "%${1}s\n" | tr ' ' "${2}"
}

help_func() {
    local DESCRIPTION="Resize Images Quickly "
    local HELP=(
        "   Description: ${DESCRIPTION}"
        "---------------------------------------------------------------------------"
        "   -h/--help       Print help for this program"
        "---------------------------------------------------------------------------"
        "   -o/--overwrite      Overwrite images with resized image"
        "   -n/--noverwrite     [Default] Resized images saved to {image_name}-xxxx"
        "---------------------------------------------------------------------------"
        "   -r/--resize (Int)   Set resize percentage"
        "                       [Default]: ${RESIZE}"
        "---------------------------------------------------------------------------"
        "   -x/--width  (Int)   Set lower limit for width of image to  resize"
        "                       [Default]: ${X_LIM}"
        "---------------------------------------------------------------------------"
        "   -y/--height (Int)   Set lower limit for height of image to resize"
        "                       [Default]: ${Y_LIM}"
        "---------------------------------------------------------------------------"
        "   -d/--dir    (Path)  Set directory for pictures to resize"
        "                       [Default]: Current Directory"
    )
    local WIDTH="${#HELP[1]}"
    print_x "${WIDTH}" '-'
    for i in "${HELP[@]}" ; do
        echo "${i}"
    done
    print_x "${WIDTH}" '-'
}

handle_arguments() {
    case "${1,,}" in
        -h|--help       ) help_func; exit
    ;;  -x|--width      ) X_LIM="${2}"; shift 1
    ;;  -y|--height     ) Y_LIM="${2}"; shift 1
    ;;  -r|--resize     ) RESIZE="${2}"; shift 1
    ;;  -o|--overwrite  ) OVERWRITE="1"; shift 1
    ;;  -n|--noverwrite ) OVERWRITE="0"; shift 1
    ;;  -*              ) echo "Invalid argument - ignoring"
    ;;   *              ) return
    ;; esac
    handle_arguments "${@:2}"
}

get_random() {
    grep -Poa -m "${1}" '^[a-zA-Z0-9]' </dev/urandom | tr -d '\n'
}

resize_photo() {
    local x y
    local new_file="${1}"
    read -r x y < <(identify -format '%w %h' "${1}")
    if [[ "${x}" -gt "${X_LIM}" ]] && [[ "${y}" -gt "${Y_LIM}" ]] ; then
        if [[ "${OVERWRITE}" -eq 0 ]] ; then
            new_file="${1%.*}${RANDOM_FOUR}.${1##*.}"
        fi
        echo "Resizing '${1}'"
        convert "${1}" -adaptive-resize "${RESIZE}%" "${new_file}"
        echo "Outputted to '${new_file}'"
        echo "--------------------------"
        return 0
    else
        return 1
    fi
}

resize_total() {
    while read -r -d $'\0' f; do
        # Checks if file is not empty #
        if [[ -s "${f}" ]] ; then
            resize_photo "${f}"
        fi
    done < <(find . -type f \( -iname '*.jpg' -o -iname '*.jpeg' -o -iname '*.png' -o -iname '*.webp' \) -printf "%f\0")
}

set_up() {
    RANDOM_FOUR="$(get_random 4)"
    RESIZE="$((100 - RESIZE))"
    cd "${DIR}" || { echo "Can't cd into '${DIR}'"; exit 1; }
    if [[ "${RESIZE}" -le 0 ]] || [[ "${RESIZE}" -ge 100 ]] ; then
        echo "Incorrect value for Resize"; exit 1
    fi
}

main() {
    # Set Arguments                     #
    handle_arguments "${@}"
    # Set Up and Validate Variables     "
    set_up
    # Start Program                     #
    resize_total
}

main "${@}"

####################
) #---END-SUBSHELL-#
####################

