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
NID=2425

print-usage() {
	local scr=${0##*/}

	cat <<-EOF
		USAGE: $scr [OPTIONS]

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
		      $ $scr input mute

		    Raise speaker volume:
		      $ $scr output raise

		    Lower speaker volume by 5:
		      $ $scr output lower 5
	EOF
	exit 1
}

check-muted() {
	local muted
	muted=$(pactl "get-$dev_mute" "$dev" | awk '{print $2}')

	local state
	case $muted in
		'yes') state='Muted' ;;
		'no') state='Unmuted' ;;
	esac

	echo "$state"
}

get-volume() {
	local vol
	vol=$(pactl "get-$dev_vol" "$dev" | awk '{print $5}' | tr -d '%')

	echo "$vol"
}

get-icon() {
	local state vol
	state=$(check-muted)
	vol=$(get-volume)

	local icon
	local new_vol=${1:-$vol}

	if [[ $state == 'Muted' ]]; then
		icon="$dev_icon-muted"
	else
		if ((new_vol < ((MAX * 33) / 100))); then
			icon="$dev_icon-low"
		elif ((new_vol < ((MAX * 66) / 100))); then
			icon="$dev_icon-medium"
		else
			icon="$dev_icon-high"
		fi
	fi

	echo "$icon"
}

toggle-mute() {
	pactl "set-$dev_mute" "$dev" toggle

	local state icon
	state=$(check-muted)
	icon=$(get-icon)

	notify-send "$title: $state" -i "$icon" -r $NID
}

set-volume() {
	local vol
	vol=$(get-volume)

	local new_vol
	case $action in
		'raise')
			new_vol=$((vol + value))
			((new_vol > MAX)) && new_vol=$MAX
			;;
		'lower')
			new_vol=$((vol - value))
			((new_vol < MIN)) && new_vol=$MIN
			;;
	esac

	pactl "set-$dev_vol" "$dev" "${new_vol}%"

	local icon
	icon=$(get-icon "$new_vol")

	notify-send "$title: ${new_vol}%" -h int:value:$new_vol -i "$icon" -r $NID
}

main() {
	device=$1
	action=$2
	value=${3:-$VALUE}

	! ((value > 0)) && print-usage

	case $device in
		'input')
			dev='@DEFAULT_SOURCE@'
			dev_mute='source-mute'
			dev_vol='source-volume'
			dev_icon='mic-volume'
			title='Microphone'
			;;
		'output')
			dev='@DEFAULT_SINK@'
			dev_mute='sink-mute'
			dev_vol='sink-volume'
			dev_icon='audio-volume'
			title='Volume'
			;;
		*) print-usage ;;
	esac

	case $action in
		'mute') toggle-mute ;;
		'raise' | 'lower') set-volume ;;
		*) print-usage ;;
	esac
}

main "$@"
