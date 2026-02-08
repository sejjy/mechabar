#!/usr/bin/env bash
#
# Adjust screen brightness and send a notification with the current level
#
# Requirements:
# - brightnessctl
# - notify-send (libnotify)
#
# Author:  Jesse Mirabel <sejjymvm@gmail.com>
# Date:    August 28, 2025
# License: MIT

DEF_VALUE=1

usage() {
	local script=${0##*/}

	cat >&2 <<- EOF
		USAGE: $script {up|down} [value]

		Adjust screen brightness and send a notification with the current level

		OPTIONS:
		  up   [value]    Increase brightness by [value] (default: $DEF_VALUE)
		  down [value]    Decrease brightness by [value] (default: $DEF_VALUE)

		EXAMPLES:
		  Increase brightness:
		    $ $script up

		  Decrease brightness by 5:
		    $ $script down 5
	EOF
}

main() {
	local action=$1
	local value=${2:-$DEF_VALUE}

	if ((value < 1)); then
		usage
		return 1
	fi

	case $action in
		up | down)
			local sign

			case $action in
				up)   sign='+' ;;
				down) sign='-' ;;
			esac

			brightnessctl -n set "${value}%${sign}" > /dev/null

			local level
			level=$(brightnessctl -m | awk -F ',' '{print $4}')

			notify-send "Brightness: $level" -h int:value:"$level" -i \
				"contrast" -h string:x-canonical-private-synchronous:backlight
			;;
		*)
			usage
			return 1
			;;
	esac
}

main "$@"
