#!/usr/bin/env bash
#
# Adjust input and output volume using pactl
#
# Author: Jesse Mirabel <github.com/sejjy>
# Created: September 07, 2025
# License: MIT

VALUE=1
NID=2425 # Notification ID

usage() {
	printf '\nUsage: %s [OPTIONS]\n' "$0"
	printf '\nAdjust input and output volume using pactl\n'
	printf '\nOPTIONS:'
	printf "\n    input            Set device as '@DEFAULT_SOURCE@'"
	printf "\n    output           Set device as '@DEFAULT_SINK@'\n"
	printf '\n    mute             Toggle device mute\n'
	printf '\n    raise <value>    Increase volume by <value>'
	printf '\n    lower <value>    Decrease volume by <value>'
	printf '\n                       - Default <value>: %d\n' $VALUE
	printf '\nEXAMPLES:'
	printf '\n    Mute output device:'
	printf '\n      $ %s output mute\n' "$0"
	printf '\n    Increase input volume by 5:'
	printf '\n      $ %s input raise 5\n' "$0"
	printf '\n    Decrease output volume by the default <value>:'
	printf '\n      $ %s output lower' "$0"
	printf "\n        - Same as passing 'output lower %d'\n" $VALUE

	exit 1
}

get-icon() {
	local icon_name=$1
	local volume=$2
	local icon

	if [[ $volume == 'Muted' ]]; then
		icon="$icon_name-muted"
	elif ((volume < 33)); then
		icon="$icon_name-low"
	elif ((volume < 66)); then
		icon="$icon_name-medium"
	else
		icon="$icon_name-high"
	fi

	echo "$icon"
}

get-info() {
	local status=$1
	local volume=$2
	local default_device=$3
	local current_volume output current_status

	current_volume=$(pactl "$volume" "$default_device" |
		awk '{print $5}' | tr -d %)

	output=$(pactl "$status" "$default_device")
	case $output in
		*yes) current_status='Unmuted' ;;
		*no) current_status='Muted' ;;
	esac

	echo "$current_volume" "$current_status"
}

volumectl() {
	local device=$1
	local action=$2
	local value=$3
	local status volume default_device title icon_name
	local output current_volume current_status icon new_volume

	case $device in
		'input')
			status='source-mute'
			volume='source-volume'
			default_device='@DEFAULT_SOURCE@'
			title='Microphone'
			icon_name='mic-volume'
			;;
		'output')
			status='sink-mute'
			volume='sink-volume'
			default_device='@DEFAULT_SINK@'
			title='Volume'
			icon_name='audio-volume'
			;;
	esac

	output=$(get-info "get-$status" "get-$volume" "$default_device")
	read -r current_volume current_status <<<"$output"

	case $action in
		'mute')
			pactl "set-$status" "$default_device" toggle

			icon=$(get-icon "$icon_name" "$current_status")
			notify-send "$title: $current_status" -i "$icon" -r $NID
			exit 0
			;;
		'raise')
			new_volume=$((current_volume + value))
			((new_volume > 100)) && new_volume=100
			;;
		'lower')
			new_volume=$((current_volume - value))
			((new_volume < 0)) && new_volume=0
			;;
	esac

	pactl "set-$volume" "$default_device" "$new_volume%"

	icon=$(get-icon "$icon_name" "$new_volume")
	notify-send "$title: $new_volume" -h int:value:"$new_volume" -i "$icon" -r $NID
}

main() {
	local device=$1
	local action=$2
	local value=${3:-$VALUE}

	case $device in
		'input' | 'output')
			case $action in
				'mute' | 'raise' | 'lower')
					volumectl "$device" "$action" "$value"
					;;
				*) usage ;;
			esac
			;;
		*) usage ;;
	esac
}

main "$@"
