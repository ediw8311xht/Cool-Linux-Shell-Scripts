#!/bin/bash



max_iterations='10'
while [[ count++ -lt "${max_iterations}" ]] && a="$(ps ax | grep -Pi 'd[e]luged')" && [[ -n "${a}" ]] ; do
    killall 'deluged'
    sleep 1
done

cp ~/.bash_history2 "${BASH_HISTORY_SAVE:-"$HOME/Documents/"}/bash_history_$(date)"
i3-msg 'exit'

