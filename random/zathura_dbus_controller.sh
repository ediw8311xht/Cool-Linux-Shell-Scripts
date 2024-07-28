#!/bin/bash

# shellcheck disable=SC2295
# For line 34-35, matching on ${DELIM}

script_main() (
    set -eu
    #-------DMENU-----------------#
    DMENU_SETTINGS=(
        -i
        -l  '19'
        -b
        -x  '20'
        -y  '20'
        -w  '800'
        -sb '#002255'
        -sf '#FFFFFF'
        -nf '#999999'
        -nb '#000000'
        -fn 'Hermit:style=Regular:pixelsize=11:antialias=true:autohint=true'
        -p  '>'
    )
    #-------APP-INFO--------------#
    SCRIPT_NAME="$(basename "${0}")"
    APP_NAME='zathura'
    APP_ORG='/org/pwmt/zathura'
    APP_INT='org.pwmt.zathura'
    #-------DATA------------------#
    DATA_DIR="${HOME}/.local/data/zathura_dbus_controller"
    DATA_FILE="${DATA_DIR}/data.txt"
    MOST_RECENT="${DATA_DIR}/most_recent.txt"
    #-------SCRIPT-VAR------------#
    DELIM=' :::: '
    FILENAME=""

    #-------UTILITY-FUNCTIONS-----#
    make_data_dir()             { mkdir -p  "${DATA_DIR}"  ; touch "${DATA_FILE}"   ; }
    reset_data_dir()            { trash-put "${DATA_FILE}" ; make_data_dir          ; }
    parse_busname()             { echo "${1#*${DELIM}}"; }
    parse_filename()            { echo "${1%${DELIM}*}"; }
    msg()                       { notify-send "${SCRIPT_NAME}$(printf "\n    %s"  "${@}")"; }

    #-------MOST-RECENT-----------#
    set_most_recent()           { echo "${1}" > "${MOST_RECENT}"; }
    get_most_recent()           { cat "${MOST_RECENT}"; }
    most_recent_filename()      { get_filename "$(get_most_recent)"; }

    #-------DBUS------------------#
    get_user_bus_names()        { busctl --user --no-legend | awk -F ' ' '{ printf $1"\0" }'; }
    get_application_bus_names() { get_user_bus_names | grep -Fz "${APP_NAME}" | sort -zr; }
    #-------SET-GET-CALL----------#
    get_dbus_property()         { busctl --user get-property "${1}" "${APP_ORG}" "${APP_INT}" "${2}" | grep -Pio '^[^ ]+[ ]*\K.+(?=[ ]*)$'; }
    call_dbus_method()          { busctl --user call         "${1}" "${APP_ORG}" "${APP_INT}" "${@:2}"; }
    get_filename()              { get_dbus_property "${1}" "filename"  | grep -Pio '(?<=^["]).*(?=["][ ]*$)'; }
    exec_command()              { busctl --user call "${1}" "${APP_ORG}" "${APP_INT}" "ExecuteCommand" s "${@:2}" ; }
    #set_dbus_property()         { busctl --user set-property "${1}" "${APP_ORG}" "${APP_INT}" "${2}" "${3}" "${4}"; }

    #-------PAGE-NUMBER-----------#
    toggle_recolor()            { exec_command "$(get_most_recent)" "set recolor"; }
    get_page_number()           { get_dbus_property "$(get_most_recent)" "pagenumber"; }
    set_page_number()           { call_dbus_method "$(get_most_recent)" "GotoPage" "u" "${1}"; }
    next_page()                 { set_page_number "$(( "$(get_page_number)" + 1))"; }
    prev_page()                 { set_page_number "$(( "$(get_page_number)" - 1))"; }

    get_bus_by_filename() {
        if [[ "${FILENAME}" = "" ]] ; then
            cat "${MOST_RECENT}"
        else
            local data_line
            while read -r -d $'\n' data_line ; do
                if parse_filename "${data_line}" | grep -Fq "${FILENAME}" ; then
                    parse_busname "${data_line}"
                fi
            done < "${DATA_FILE}"
        fi
    }
    get_busses() {
        local f busname
        reset_data_dir
        while read -r -d $'\0' busname; do
            if f="$(get_filename "${busname}")" ; then
                echo "${f}${DELIM}${busname}" >> "${DATA_FILE}"
                if [[ ! -f "${MOST_RECENT}" ]] || [[ "${1:-""}" = "reset_recent" ]] ; then
                    set_most_recent "${busname}"
                fi
            fi
        done < <(get_application_bus_names)
    }
    get_filenames() {
        local data_line
        while read -r -d $'\n' data_line ; do
            parse_filename "${data_line}"
        done < "${DATA_FILE}"
    }
    dmenu_get_filename() { get_filenames | dmenu "${DMENU_SETTINGS[@]}"; }
    main() {
        make_data_dir
        get_busses
        while [[ "${#}" -gt 0 ]] ; do
            case "${1}" in
                -g|--get)           get_busses "reset_recent" && msg "updated bus names" "$(get_most_recent)"
            ;;  -s|--set)           set_most_recent "$(get_bus_by_filename)"
            ;;  -d|--set-dmenu)     FILENAME="$(dmenu_get_filename)"; set_most_recent "$(get_bus_by_filename)" && msg "set most recent" "$(get_most_recent)"
            ;;  -f|--files)         get_filenames
            ;;  -c|--current)       most_recent_filename
            ;;  -p|--pagenumber)    get_page_number
            ;;  -r|--recolor)       toggle_recolor
            ;;  -[0-9]*)            set_page_number "${1/-/}"
            ;;  -p+|--nextpage)     next_page
            ;;  -p-|--prevpage)     prev_page
            ;;  -*)                 echo "Invalid option"; exit 1
            ;;   *)                 FILENAME="${1}"
            esac
            shift 1
        done
    }
    main "${@}"
)

script_main "${@}"

