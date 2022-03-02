#!/bin/bash


echo $(xrandr --listmonitors | grep -Po "(?<= )(HDMI|VGA|DVI)[^\ ]+$")
