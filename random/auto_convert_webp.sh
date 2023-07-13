#!/bin/bash


replace_g() {
    while read -r -d $'\0' oldfile ; do

        newfile="${oldfile::-5}.png"
        echo $'\n\n'"    IN:  ${oldfile}"$'\n'"    OUT: ${newfile}"

        if dwebp "${oldfile}" -o "${newfile}" && [ -f "${newfile}" ] ; then
            echo '>>>>-SUCCESS:-Png-created-successfully'

            mv "${oldfile}" "${1:-"/home/$USER/.Trash"}"    \
                && echo '>>>> :  '"${oldfile}"'  DELETED'   \
                || echo "!!!! ERROR: FILE NOT DELETED !!!!"
        else
            echo "!!!!-ERROR:-FILE-NOT-CREATED" ; continue
        fi
    done < <(find . -name "*.webp" -printf '%f\0')

}

cd "${1:-"/home/$USER/Pictures"}" || exit
replace_g "${@: 2}"
