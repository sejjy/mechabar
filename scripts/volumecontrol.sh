#!/bin/bash

# Define functions
print_error() {
    cat <<"EOF"
Usage: ./volumecontrol.sh -[device] <actions>
...valid devices are...
    i   -- input device
    o   -- output device
    p   -- player application
...valid actions are...
    i   -- increase volume [+5]
    d   -- decrease volume [-5]
    m   -- mute [x]
EOF
    exit 1
}

send_notification() {
    notify-send -r 91190 "Volume: ${vol}%"
}

notify_mute() {
    mute=$(pamixer "${srce}" --get-mute)
    if [ "${mute}" = "true" ]; then
        notify-send -r 91190 "Muted"
    else
        notify-send -r 91190 "Unmuted"
    fi
}

action_pamixer() {
    pamixer "${srce}" -"${1}" "${step}"
    vol=$(pamixer "${srce}" --get-volume)
}

action_playerctl() {
    [ "${1}" = "i" ] && pvl="+" || pvl="-"
    playerctl --player="${srce}" volume 0.0"${step}""${pvl}"
    vol=$(playerctl --player="${srce}" volume | awk '{ printf "%.0f\n", $0 * 100 }')
}

select_output() {
    if [ "$@" ]; then
        desc="$*"
        device=$(pactl list sinks | grep -C2 -F "Description: $desc" | grep Name | cut -d: -f2 | xargs)
        if pactl set-default-sink "$device"; then
            notify-send -r 91190 "Activated: $desc"
        else
            notify-send -r 91190 "Error activating $desc"
        fi
    else
        pactl list sinks | grep -ie "Description:" | awk -F ': ' '{print $2}' | sort
    fi
}

# Evaluate device option
while getopts iops: DeviceOpt; do
    case "${DeviceOpt}" in
    i)
        nsink=$(pamixer --list-sources | awk -F '"' 'END {print $(NF - 1)}')
        [ -z "${nsink}" ] && echo "ERROR: Input device not found..." && exit 0
        ctrl="pamixer"
        srce="--default-source"
        ;;
    o)
        nsink=$(pamixer --get-default-sink | awk -F '"' 'END{print $(NF - 1)}')
        [ -z "${nsink}" ] && echo "ERROR: Output device not found..." && exit 0
        ctrl="pamixer"
        srce=""
        ;;
    p)
        nsink=$(playerctl --list-all | grep -w "${OPTARG}")
        [ -z "${nsink}" ] && echo "ERROR: Player ${OPTARG} not active..." && exit 0
        ctrl="playerctl"
        srce="${nsink}"
        ;;
    s)
        # shellcheck disable=SC2034
        default_sink="$(pamixer --get-default-sink | awk -F '"' 'END{print $(NF - 1)}')"
        selected_sink="$(select_output "${@}")"
        select_output "$selected_sink"
        exit
        ;;
    *) print_error ;;
    esac
done

# Set default variables
shift $((OPTIND - 1))
step="${2:-5}"

# Execute action
case "${1}" in
i) action_"${ctrl}" i ;;
d) action_"${ctrl}" d ;;
m) "${ctrl}" "${srce}" -t && notify_mute && exit 0 ;;
*) print_error ;;
esac

send_notification
