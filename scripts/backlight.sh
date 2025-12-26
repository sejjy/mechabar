#!/usr/bin/env bash
#
# Adjust screen brightness and send a notification with the current level
#
# Requirements:
# 	brightnessctl
# 	notify-send (libnotify)
#
# Author:  Jesse Mirabel <sejjymvm@gmail.com>
# Date:    August 28, 2025
# License: MIT

VALUE=1

usage() {
	cat <<- EOF
		USAGE: ${0##*/} [OPTIONS]

		Adjust screen brightness and send a notification with the current level

		OPTIONS:
		    up   <value>    Increase brightness by <value>
		    down <value>    Decrease brightness by <value>
		                        Default value: $VALUE

		EXAMPLES:
		    Increase brightness:
		        $ ${0##*/} up

		    Decrease brightness by 5:
		        $ ${0##*/} down 5
	EOF
	exit 1
}

main() {
	local action=$1
	local value=${2:-$VALUE}

	((value > 0)) || usage

	case $action in
		"up" | "down")
			case $action in
				"up") brightnessctl -n set "${value}%+" > /dev/null ;;
				"down") brightnessctl -n set "${value}%-" > /dev/null ;;
			esac

			local level
			level=$(brightnessctl -m | awk -F "," '{print $4}')

			notify-send "Brightness: $level" -h int:value:"$level" -i \
				"contrast" -h string:x-canonical-private-synchronous:backlight
			;;
		*) usage ;;
	esac
}

main "$@"
