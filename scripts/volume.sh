#!/usr/bin/env bash
#
# Adjust default device volume and send a notification with the current level
#
# Requirements:
# - pactl (libpulse)
# - notify-send (libnotify)
#
# Author:  Jesse Mirabel <sejjymvm@gmail.com>
# Date:    September 07, 2025
# License: MIT

DEF_VALUE=1
MIN=0
MAX=100

usage() {
	local script=${0##*/}

	cat >&2 <<- EOF
		USAGE: $script {input|output} {mute|raise|lower} [value]

		Adjust default device volume and send a notification with the current level

		DEVICE:
		  input            Use "@DEFAULT_SOURCE@" (microphone)
		  output           Use "@DEFAULT_SINK@" (speaker/headphones)

		OPTIONS:
		  mute             Toggle device mute
		  raise [value]    Raise volume by [value] (default: $DEF_VALUE)
		  lower [value]    Lower volume by [value] (default: $DEF_VALUE)

		EXAMPLES:
		  Toggle microphone mute:
		    $ $script input mute

		  Raise speaker volume:
		    $ $script output raise

		  Lower speaker volume by 5:
		    $ $script output lower 5
	EOF
}

pactl() {
	command pactl "$1" "$DEV_DEF" "${@:2}"
}

get_state() {
	local state
	state=$(pactl "get-$DEV_STATE" | awk '{print $2}')

	case $state in
		yes) printf "Muted" ;;
		no)  printf "Unmuted" ;;
	esac
}

get_volume() {
	pactl "get-$DEV_VOLUME" | awk '{print $5}' | tr -d '%'
}

get_icon() {
	local state level

	state=$(get_state)
	level=$(get_volume)

	local icon
	local new_level=${1:-$level}

	if [[ $state == Muted ]]; then
		icon="$DEV_ICON-muted"
	else
		if ((new_level < MAX * 33 / 100)); then
			icon="$DEV_ICON-low"
		elif ((new_level < MAX * 66 / 100)); then
			icon="$DEV_ICON-medium"
		else
			icon="$DEV_ICON-high"
		fi
	fi

	printf "%s" "$icon"
}

set_state() {
	pactl "set-$DEV_STATE" toggle

	local state icon

	state=$(get_state)
	icon=$(get_icon)

	notify-send "$DEV_NAME: $state" -i "$icon" \
		-h string:x-canonical-private-synchronous:volume
}

set_volume() {
	local level
	level=$(get_volume)

	local new_level

	case $ACTION in
		raise)
			new_level=$((level + VALUE))
			if ((new_level > MAX)); then
				new_level=$MAX
			fi
			;;
		lower)
			new_level=$((level - VALUE))
			if ((new_level < MIN)); then
				new_level=$MIN
			fi
			;;
	esac

	pactl "set-$DEV_VOLUME" "$new_level%"

	local icon
	icon=$(get_icon $new_level)

	notify-send "$DEV_NAME: $new_level%" -h int:value:$new_level -i "$icon" \
		-h string:x-canonical-private-synchronous:volume
}

main() {
	DEVICE=$1
	ACTION=$2
	VALUE=${3:-$DEF_VALUE}

	if ((VALUE < 1)); then
		usage
		return 1
	fi

	case $DEVICE in
		input)
			DEV_DEF="@DEFAULT_SOURCE@"
			DEV_STATE="source-mute"
			DEV_VOLUME="source-volume"
			DEV_ICON="mic-volume"
			DEV_NAME="Microphone"
			;;
		output)
			DEV_DEF="@DEFAULT_SINK@"
			DEV_STATE="sink-mute"
			DEV_VOLUME="sink-volume"
			DEV_ICON="audio-volume"
			DEV_NAME="Volume"
			;;
		*)
			usage
			return 1
			;;
	esac

	case $ACTION in
		mute)          set_state ;;
		raise | lower) set_volume ;;
		*)
			usage
			return 1
			;;
	esac
}

main "$@"
