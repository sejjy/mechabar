#!/usr/bin/env bash
#
# Adjust default device volume and send a notification with the current level
#
# Requirements:
# 	pactl (libpulse)
# 	notify-send (libnotify)
#
# Author:  Jesse Mirabel <sejjymvm@gmail.com>
# Date:    September 07, 2025
# License: MIT

VALUE=1
MIN=0
MAX=100

usage() {
	cat <<- EOF
		USAGE: ${0##*/} [OPTIONS]

		Adjust default device volume and send a notification with the current level

		OPTIONS:
		    input            Set device as "@DEFAULT_SOURCE@"
		    output           Set device as "@DEFAULT_SINK@"

		    mute             Toggle device mute

		    raise <value>    Raise volume by <value>
		    lower <value>    Lower volume by <value>
		                         Default value: $VALUE

		EXAMPLES:
		    Toggle microphone mute:
		        $ ${0##*/} input mute

		    Raise speaker volume:
		        $ ${0##*/} output raise

		    Lower speaker volume by 5:
		        $ ${0##*/} output lower 5
	EOF
	exit 1
}

pactl() {
	command pactl "$1" "$default" "${@:2}"
}

get-state() {
	local s; s=$(pactl "get-$state" | awk '{print $2}')

	case $s in
		"yes") printf "Muted" ;;
		"no") printf "Unmuted" ;;
	esac
}

get-volume() {
	pactl "get-$volume" | awk '{print $5}' | tr -d "%"
}

get-icon() {
	local s; s=$(get-state)
	local v; v=$(get-volume)
	local level=${1:-$v}

	if [[ $s == "Muted" ]]; then
		printf "%s" "$icon-muted"
	else
		if ((level < ((MAX * 33) / 100))); then
			printf "%s" "$icon-low"
		elif ((level < ((MAX * 66) / 100))); then
			printf "%s" "$icon-medium"
		else
			printf "%s" "$icon-high"
		fi
	fi
}

set-volume() {
	local level; level=$(get-volume)
	local nlevel

	case $action in
		"raise")
			nlevel=$((level + value))
			((nlevel > MAX)) && nlevel=$MAX
			;;
		"lower")
			nlevel=$((level - value))
			((nlevel < MIN)) && nlevel=$MIN
			;;
	esac

	pactl "set-$volume" "${nlevel}%"

	local i; i=$(get-icon "$nlevel")
	notify-send "$name: ${nlevel}%" -h int:value:$nlevel -i "$i" \
		-h string:x-canonical-private-synchronous:volume
}

main() {
	device=$1
	action=$2
	value=${3:-$VALUE}

	((value > 0)) || usage

	case $device in
		"input")
			default="@DEFAULT_SOURCE@"
			state="source-mute"
			volume="source-volume"
			icon="mic-volume"
			name="Microphone"
			;;
		"output")
			default="@DEFAULT_SINK@"
			state="sink-mute"
			volume="sink-volume"
			icon="audio-volume"
			name="Volume"
			;;
		*) usage ;;
	esac

	case $action in
		"mute")
			pactl "set-$state" toggle

			local s; s=$(get-state)
			local i; i=$(get-icon)
			notify-send "$name: $s" -i "$i" \
				-h string:x-canonical-private-synchronous:volume
			;;
		"raise" | "lower") set-volume ;;
		*) usage ;;
	esac
}

main "$@"
