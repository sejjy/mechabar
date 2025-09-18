#!/usr/bin/env bash
#
# Adjust brightness level using brightnessctl
#
# Author: Jesse Mirabel <github.com/sejjy>
# Created: August 28, 2025
# License: MIT

main() {
	local action=$1
	local level

	case $action in
		up) brightnessctl -n set 1%+ ;;
		down) brightnessctl -n set 1%- ;;
	esac

	level=$(brightnessctl -m | awk -F',' '{print $4}')
	notify-send "Brightness: $level" -h int:value:"$level" -i 'contrast' -r 2825
}

main "$@"
