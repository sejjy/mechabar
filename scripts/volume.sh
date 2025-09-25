#!/usr/bin/env bash
#
# Control default input and output device volume using pactl
#
# Author: Jesse Mirabel <github.com/sejjy>
# Created: September 07, 2025
# License: MIT

VALUE=1
MIN=0
MAX=100
ID=2425

print-usage() {
	cat <<-EOF
		USAGE: ${0} [OPTIONS]

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
	local new_vol=$1
	local icon

	if [[ $new_vol == 'Muted' ]]; then
		icon="$ICON-muted"
	elif ((new_vol < ((MAX * 33) / 100))); then
		icon="$ICON-low"
	elif ((new_vol < ((MAX * 66) / 100))); then
		icon="$ICON-medium"
	else
		icon="$ICON-high"
	fi

	echo "$icon"
}

toggle-mute() {
	local mute icon

	pactl "set-$MUTE" "$DEV" toggle

	case $(pactl "get-$MUTE" "$DEV" | awk '{print $2}') in
		yes) mute='Muted' ;;
		no) mute='Unmuted' ;;
	esac

	icon=$(get-icon "$mute")
	notify-send "$TITLE: $mute" -i "$icon" -r $ID
}

set-volume() {
	local action=$1
	local value=$2
	local vol new_vol icon

	vol=$(pactl "get-$VOL" "$DEV" | awk '{print $5}' | tr -d '%')

	case $action in
		raise)
			new_vol=$((vol + value))
			((new_vol > MAX)) && new_vol=$MAX
			;;
		lower)
			new_vol=$((vol - value))
			((new_vol < MIN)) && new_vol=$MIN
			;;
	esac

	pactl "set-$VOL" "$DEV" "${new_vol}%"

	icon=$(get-icon "$new_vol")
	notify-send "$TITLE: $new_vol" -h int:value:"$new_vol" -i "$icon" -r $ID
}

main() {
	local device=$1
	local action=$2
	local value=${3:-$VALUE}

	! ((value > 0 )) && print-usage

	case $device in
		input)
			DEV='@DEFAULT_SOURCE@'
			MUTE='source-mute' VOL='source-volume'
			TITLE='Microphone' ICON='mic-volume'
			;;
		output)
			DEV='@DEFAULT_SINK@'
			MUTE='sink-mute'   VOL='sink-volume'
			TITLE='Volume'     ICON='audio-volume'
			;;
		*) print-usage ;;
	esac

	case $action in
		mute) toggle-mute ;;
		raise | lower) set-volume "$action" "$value" ;;
		*) print-usage ;;
	esac
}

main "$@"
