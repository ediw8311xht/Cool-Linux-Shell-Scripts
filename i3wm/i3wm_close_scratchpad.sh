#!/bin/bash

GOT=$(ps ax | grep -Po '([0-9])+(?= [\?|p].+([i]3wm_scratchpad_))')

kill $GOT

