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
	local level=$1
	local icon

	if [[ $level == 'Muted' ]]; then
		icon="$dev_icon-muted"
	elif ((level < ((MAX * 33) / 100))); then
		icon="$dev_icon-low"
	elif ((level < ((MAX * 66) / 100))); then
		icon="$dev_icon-medium"
	else
		icon="$dev_icon-high"
	fi

	echo "$icon"
}

toggle-mute() {
	pactl "set-$dev_mute" "$dev" toggle

	local state
	case $(pactl "get-$dev_mute" "$dev" | awk '{print $2}') in
		yes) state='Muted' ;;
		no) state='Unmuted' ;;
	esac

	local icon
	icon=$(get-icon "$state")

	notify-send "$title: $state" -i "$icon" -r $ID
}

set-volume() {
	local vol
	vol=$(pactl "get-$dev_vol" "$dev" | awk '{print $5}' | tr -d '%')

	local new_vol
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

	pactl "set-$dev_vol" "$dev" "${new_vol}%"

	local icon
	icon=$(get-icon $new_vol)

	notify-send "$title: $new_vol" -h int:value:$new_vol -i "$icon" -r $ID
}

main() {
	device=$1
	action=$2
	value=${3:-$VALUE}

	! ((value > 0)) && print-usage

	case $device in
		input)
			dev='@DEFAULT_SOURCE@'
			dev_mute='source-mute' dev_vol='source-volume'
			title='Microphone'     dev_icon='mic-volume'
			;;
		output)
			dev='@DEFAULT_SINK@'
			dev_mute='sink-mute' dev_vol='sink-volume'
			title='Volume'       dev_icon='audio-volume'
			;;
		*) print-usage ;;
	esac

	case $action in
		mute) toggle-mute ;;
		raise | lower) set-volume ;;
		*) print-usage ;;
	esac
}

main "$@"
