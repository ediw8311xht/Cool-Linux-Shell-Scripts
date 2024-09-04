#!/bin/bash

# shellcheck disable=SC2295
# For line 34-35, matching on ${DELIM}

script_main() (
    #set -eu
    #-------ZATHURA-DB-VARS-------#
        ZATHURA_DATA_DIR="${XDG_DATA_HOME:-"${HOME}/.local/share"}"
        HFILE="${ZATHURA_DATA_DIR}/zathura/bookmarks.sqlite"
    #-------APP-INFO--------------#
        BUSLIST=()
        DMENU_SCRIPT="${HOME}/bin/my_dmenu.sh"
        if [[ ! -f "${DMENU_SCRIPT}" ]] ; then DMENU_SCRIPT="dmenu"; fi
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
    read_histfile() {
        while read -r -d $'\n' n ; do
            if [[ -f "${n}" ]] ; then
                printf '%s\n' "${n}"
            fi
        done < <(sqlite3 "${HFILE}" "SELECT file FROM fileinfo ORDER BY time" | tac)
    }
    #-------UTILITY-FUNCTIONS-----#
    make_data_dir()             { mkdir -p  "${DATA_DIR}"  ; touch "${DATA_FILE}"   ;  touch "${MOST_RECENT}"; }
    reset_data_dir()            { trash-put "${DATA_FILE}" ; make_data_dir          ; }
    parse_busname()             { echo "${1#*${DELIM}}"; }
    parse_filename()            { echo "${1%${DELIM}*}"; }
    in_buslist()                { printf '%s\0' "${BUSLIST[@]}" | grep -Fqzx "$(get_most_recent)"; }
    msg()                       { notify-send "${SCRIPT_NAME}$(printf "\n    %s"  "${@}")"; }

    #-------MOST-RECENT-----------#
    set_most_recent()           { echo "${1}" > "${MOST_RECENT}"; }
    get_most_recent()           { cat "${MOST_RECENT}"; }
    most_recent_filename()      { get_filename "$(get_most_recent)"; }
    check_most_recent() {
        if [[ "${#BUSLIST[@]}" -le 0 ]] ; then
            set_most_recent ""
        elif [[ "${1:-}" = "reset_recent" ]] || ! in_buslist "$(get_most_recent)" ; then
            echo "HI"
            set_most_recent "${BUSLIST[0]}"
        fi
    }

    #-------DBUS------------------#
    get_user_bus_names()        { busctl --user --no-legend | awk -F ' ' '{ printf $1"\0" }'; }
    get_application_bus_names() { get_user_bus_names | grep -Fz "${APP_NAME}" | sort -zr; }
    #-------SET-GET-CALL----------#
    get_dbus_property()         { busctl --user get-property "${1}" "${APP_ORG}" "${APP_INT}" "${2}" | grep -Pio '^[^ ]+[ ]*\K.+(?=[ ]*)$'; }
    call_dbus_method()          { busctl --user call         "${1}" "${APP_ORG}" "${APP_INT}" "${@:2}"; }
    get_filename()              { { get_dbus_property "${1}" "filename" | grep -Pio '(?<=^["]).*(?=["][ ]*$)'; } || echo "_"; }
    exec_command()              { busctl --user call "${1}" "${APP_ORG}" "${APP_INT}" "ExecuteCommand" s "${@:2}" ; }
    #set_dbus_property()         { busctl --user set-property "${1}" "${APP_ORG}" "${APP_INT}" "${2}" "${3}" "${4}"; }

    #-------PAGE-NUMBER-----------#
    get_page_number()           { get_dbus_property "$(get_most_recent)" "pagenumber"; }
    set_page_number()           { call_dbus_method "$(get_most_recent)" "GotoPage" "u" "${1}"; }
    next_page()                 { set_page_number "$(( "$(get_page_number)" + 1))"; }
    prev_page()                 { set_page_number "$(( "$(get_page_number)" - 1))"; }

    #-------COMMANDS--------------#
    toggle_recolor()            { exec_command "$(get_most_recent)" "set recolor"; }
    open_file()                 {
        exec_command "$(get_most_recent)" "open '${1}'"
    }

    #-------DMENU-----------------#
    dmenu_get_filename()        { get_filenames | "${DMENU_SCRIPT}"; }
    dmenu_open_file()           {
        local f
        if [[ "${1:-}" = 'history' ]] ; then
            echo "HERE"
            shift 1
            f="$(read_histfile | "${DMENU_SCRIPT}")"
        else
            f="$(fd . -u -e pdf -e epub -e azw2 -e djvu -e mobi "${HOME}" | "${DMENU_SCRIPT}")"
        fi
        if [[ ! -f "${f}" ]] ; then
            return 0
        elif [[ "${#BUSLIST[@]}" -le 0 ]] || [[ "${1:-}" = 'new' ]] ; then
            zathura --fork "${f}"
            sleep 2 #sketchy solution
            get_buslist
            check_most_recent "reset_recent"
        else
            open_file "${f}"
        fi
    }

    #-------FILES-----------------#
    get_buslist()               { mapfile -d $'\0' BUSLIST < <(get_application_bus_names); }
    get_bus_by_filename() {
        if [[ "${FILENAME}" = "" ]] ; then cat "${MOST_RECENT}"
        else
            local data_line
            while read -r -d $'\n' data_line ; do
                if parse_filename "${data_line}" | grep -Fq "${FILENAME}" ; then
                    parse_busname "${data_line}"
                fi
            done < "${DATA_FILE}"
        fi
    }
    set_data_files() {
        local f
        reset_data_dir
        for busname in "${BUSLIST[@]}" ; do
            f="$(get_filename "${busname}" 2>/dev/null)"
            echo "${f}${DELIM}${busname}" >> "${DATA_FILE}"
        done
    }
    get_filenames() {
        local data_line
        while read -r -d $'\n' data_line ; do
            parse_filename "${data_line}"
        done < "${DATA_FILE}"
    }
    main() {
        get_buslist
        check_most_recent
        set_data_files
        while [[ "${#}" -gt 0 ]] ; do
            case "${1}" in
                -g|--get)           check_most_recent "reset_recent" && msg "updated bus names" "$(get_most_recent)"
            ;;  -s|--set)           set_most_recent "$(get_bus_by_filename)"
            ;;  -d|--set-dmenu)     FILENAME="$(dmenu_get_filename)"; set_most_recent "$(get_bus_by_filename)" && msg "set most recent" "$(get_most_recent)"
            ;;  -f|--files)         get_filenames
            ;;  -c|--current)       most_recent_filename
            ;;  -p|--pagenumber)    get_page_number
            ;;  -r|--recolor)       toggle_recolor
            ;;  -h|--history)       dmenu_open_file "history"
            ;;  -H|--history-new)   dmenu_open_file "history" "new"
            ;;  -o|--open)          dmenu_open_file
            ;;  -O|--open-new)      dmenu_open_file "new"
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

