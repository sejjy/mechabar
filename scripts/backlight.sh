#!/usr/bin/env bash
#
# Adjust brightness level using brightnessctl
#
# Author: Jesse Mirabel <github.com/sejjy>
# Created: August 28, 2025
# License: MIT

VALUE=1

print-usage() {
	local scr=${0##*/}

	cat <<-EOF
		USAGE: $scr [OPTIONS]

		Adjust brightness level using brightnessctl

		OPTIONS:
		    up   <value>    Increase brightness by <value>
		    down <value>    Decrease brightness by <value>
		                      Default value: $VALUE

		EXAMPLES:
		    Increase brightness:
		      $ $scr up

		    Decrease brightness by 5:
		      $ $scr down 5
	EOF
	exit 1
}

set-brightness() {
	local op
	case $action in
		'up') op='+' ;;
		'down') op='-' ;;
	esac

	brightnessctl -n set "${value}%${op}" &>/dev/null

	local level
	level=$(brightnessctl -m | awk -F ',' '{print $4}')

	notify-send "Brightness: $level" -h int:value:"$level" -i 'contrast' -r 2825
}

main() {
	local action=$1
	local value=${2:-$VALUE}

	! ((value > 0)) && print-usage

	case $action in
		'up' | 'down') set-brightness ;;
		*) print-usage ;;
	esac
}

main "$@"
