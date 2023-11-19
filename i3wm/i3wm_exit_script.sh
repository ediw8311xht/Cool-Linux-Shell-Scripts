#!/bin/bash



#max_iterations='10'
#while [[ count++ -lt "${max_iterations}" ]] && ps ax | grep -qPi 'd[e]luged' ; do
#    killall 'deluged'
#    sleep 1
#done

cp ~/.bash_history2 "${BASH_HISTORY_SAVE:-"$HOME/Documents/"}/bash_history_$(date)"
i3-msg 'exit'

