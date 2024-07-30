#!/usr/bin/env bash

rg_fzf_func() {

    local lf_script="${HOME}/bin/cd_from_lf.sh"
    local outarr dir file
    local RG_PREFIX="rg --no-search-zip --column --line-number --no-heading --color=always --smart-case"
    local INITIAL_QUERY="${*:-}"
    local OPTIONS=(
        --ansi --disabled --query "$INITIAL_QUERY"
        --bind "start:reload:$RG_PREFIX {q}"
        --bind "change:reload:sleep 0.1; $RG_PREFIX {q} || true"
        --bind "ctrl-b:become(  printf '%s\0' 'browser' {1}     )"
        --bind "ctrl-l:become(  printf '%s\0' 'lf'      {1}     )"
        --bind "ctrl-x:execute( printf '%s\0' 'xdg'     {1}     )"
        --bind "ctrl-a:become(  printf '%s\0' 'cd'      {1}     )"
        --bind "enter:become(   printf '%s\0' 'edit'    {1} {2} )"
        --delimiter :
        --preview 'bat --color=always {1} --highlight-line {2}'
        --preview-window 'right,50%,border-bottom,+{2}+3/3,~3'
    )
    if mapfile -d $'\0' outarr < <(fzf "${OPTIONS[@]}") ; then
        dir="$(dirname "${outarr[1]}")"
        file="$(basename "${outarr[1]}")"
        cd "${dir}" || { echo "Couldnt cd to '${dir}'"; exit 1; }
        case "${outarr[0]}" in
                 lf) "${lf_script}" "${file}"
        ;;  browser) "${BROWSER}" "${file}"
        ;;      xdg) xdg-open "${file}"
        ;;     edit) "${EDITOR}" "${file}" +"${outarr[2]}"
        ;; esac
    fi
}


rg_fzf_func "${@}"
