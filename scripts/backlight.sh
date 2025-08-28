#!/usr/bin/env bash

case $1 in
	'down') brightnessctl -n set 1%- ;;
	'up') brightnessctl -n set 1%+ ;;
esac

level=$(brightnessctl -m | awk -F',' '{print $4}')

notify-send "Brightness: $level" -h int:value:"$level" -i "xfpm-brightness-lcd" -r 2825
