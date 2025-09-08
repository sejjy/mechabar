#!/usr/bin/env bash

case $1 in
	'up') brightnessctl -n set 1%+ ;;
	'down') brightnessctl -n set 1%- ;;
esac

level=$(brightnessctl -m | awk -F',' '{print $4}')
notify-send "Brightness: $level" -h int:value:"$level" -i 'contrast' -r 2825
