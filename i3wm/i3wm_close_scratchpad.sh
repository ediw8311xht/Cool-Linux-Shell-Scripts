#!/bin/bash

# ASSUMES ALL YOUR i3wm SCRATCHPADS HAVE NAME i3wm_scratchpad_* on them

GOT=$(ps ax | grep -Po '([0-9])+(?= [\?|p].+([i]3wm_scratchpad_))')

kill $GOT

