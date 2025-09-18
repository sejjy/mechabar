#!/usr/bin/env bash
#
# Control default input and output device volume using pactl
#
# Author: Jesse Mirabel <github.com/sejjy>
# Created: September 07, 2025
# License: MIT

VALUE=1
MIN_VOLUME=0
MAX_VOLUME=100
NOTIF_ID=2425

print-usage() {
	cat <<-EOF
		Usage: ${0} [OPTIONS]

		Control default input and output device volume using pactl

		OPTIONS:
		    input            Set device as '@DEFAULT_SOURCE@'
		    output           Set device as '@DEFAULT_SINK@'

		    mute             Toggle device mute

		    raise <value>    Raise volume by <value>
		    lower <value>    Lower volume by <value>
		                       Default value: $VALUE

		EXAMPLES:
		    Toggle microphone mute:
		      $ ${0} input mute

		    Raise speaker volume:
		      $ ${0} output raise

		    Lower speaker volume by 5:
		      $ ${0} output lower 5
	EOF
	exit 1
}

get-icon() {
	local new_volume=$1

	if [[ $new_volume == 'Muted' ]]; then
		echo "$NOTIF_ICON-muted"
	elif ((new_volume < MAX_VOLUME * 33 / 100)); then
		echo "$NOTIF_ICON-low"
	elif ((new_volume < MAX_VOLUME * 66 / 100)); then
		echo "$NOTIF_ICON-medium"
	else
		echo "$NOTIF_ICON-high"
	fi
}

set-volume() {
	local action=$1
	local value=$2
	local volume new_volume icon

	volume=$(pactl "get-$DEVICE_VOLUME" "$DEVICE" | awk '{print $5}' |
		tr -d '%')

	case $action in
		raise)
			new_volume=$((volume + value))
			((new_volume > MAX_VOLUME)) && new_volume=$MAX_VOLUME
			;;
		lower)
			new_volume=$((volume - value))
			((new_volume < MIN_VOLUME)) && new_volume=$MIN_VOLUME
			;;
	esac

	pactl "set-$DEVICE_VOLUME" "$DEVICE" "${new_volume}%"

	icon=$(get-icon "$new_volume")
	notify-send "$NOTIF_TITLE: $new_volume" -h int:value:"$new_volume" \
		-i "$icon" -r $NOTIF_ID
}

toggle-mute() {
	local mute icon

	case $(pactl "get-$DEVICE_MUTE" "$DEVICE") in
		*yes) mute='Unmuted' ;;
		*no) mute='Muted' ;;
	esac

	pactl "set-$DEVICE_MUTE" "$DEVICE" toggle

	icon=$(get-icon "$mute")
	notify-send "$NOTIF_TITLE: $mute" -i "$icon" -r $NOTIF_ID
}

main() {
	local device=$1
	local action=$2
	local value=${3:-$VALUE}

	case $device in
		input)
			DEVICE='@DEFAULT_SOURCE@'
			DEVICE_MUTE='source-mute'; DEVICE_VOLUME='source-volume'
			NOTIF_TITLE='Microphone';  NOTIF_ICON='mic-volume'
			;;
		output)
			DEVICE='@DEFAULT_SINK@'
			DEVICE_MUTE='sink-mute'; DEVICE_VOLUME='sink-volume'
			NOTIF_TITLE='Volume';    NOTIF_ICON='audio-volume'
			;;
		*) print-usage ;;
	esac

	! ((value > 0 )) && print-usage

	case $action in
		mute) toggle-mute ;;
		raise | lower) set-volume "$action" "$value" ;;
		*) print-usage ;;
	esac
}

main "$@"
