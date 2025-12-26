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
	command pactl "$1" "$d_default" "${@:2}"
}

get-state() {
	local state
	state=$(pactl "get-$d_state" | awk '{print $2}')

	case $state in
		"yes") printf "Muted" ;;
		"no") printf "Unmuted" ;;
	esac
}

get-volume() {
	pactl "get-$d_volume" | awk '{print $5}' | tr -d "%"
}

get-icon() {
	local state level new_level
	state=$(get-state)
	level=$(get-volume)
	new_level=${1:-$level}

	if [[ $state == "Muted" ]]; then
		printf "%s" "$n_icon-muted"
	else
		if ((new_level < ((MAX * 33) / 100))); then
			printf "%s" "$n_icon-low"
		elif ((new_level < ((MAX * 66) / 100))); then
			printf "%s" "$n_icon-medium"
		else
			printf "%s" "$n_icon-high"
		fi
	fi
}

set-volume() {
	local level new_level
	level=$(get-volume)

	case $action in
		"raise")
			new_level=$((level + value))
			((new_level > MAX)) && new_level=$MAX
			;;
		"lower")
			new_level=$((level - value))
			((new_level < MIN)) && new_level=$MIN
			;;
	esac

	pactl "set-$d_volume" "${new_level}%"

	local icon
	icon=$(get-icon "$new_level")

	notify-send "$n_name: ${new_level}%" -h int:value:$new_level -i "$icon" \
		-h string:x-canonical-private-synchronous:volume
}

main() {
	device=$1
	action=$2
	value=${3:-$VALUE}

	((value > 0)) || usage

	case $device in
		"input")
			d_default="@DEFAULT_SOURCE@"
			d_state="source-mute"
			d_volume="source-volume"
			n_icon="mic-volume"
			n_name="Microphone"
			;;
		"output")
			d_default="@DEFAULT_SINK@"
			d_state="sink-mute"
			d_volume="sink-volume"
			n_icon="audio-volume"
			n_name="Volume"
			;;
		*) usage ;;
	esac

	case $action in
		"mute")
			pactl "set-$d_state" toggle

			local state icon
			state=$(get-state)
			icon=$(get-icon)

			notify-send "$n_name: $state" -i "$icon" \
				-h string:x-canonical-private-synchronous:volume
			;;
		"raise" | "lower") set-volume ;;
		*) usage ;;
	esac
}

main "$@"
