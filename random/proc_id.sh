#!/bin/bash


GOT=$(ps ax | grep --perl-regex -o "[0-9]+(?= +([\?]|(pts)\/[0-9]+).* [0-9]+:[0-9]+ ${1} .*)")
echo "${GOT}"
