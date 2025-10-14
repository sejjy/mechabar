#!/usr/bin/env bash

options=" Lock
 Shutdown
 Reboot
 Logout
 Hibernate
 Suspend"

chosen=$(echo -e "$options" | rofi -dmenu -p "Power Menu" -location 3 -yoffset 35 -lines 6 -show-icons -theme-str 'window {width: 200px; height: 190px;}' -no-fullscreen)

case "$chosen" in
    " Lock") loginctl lock-session ;;
    " Shutdown") systemctl poweroff ;;
    " Reboot") systemctl reboot ;;
    " Logout") loginctl terminate-session "$XDG_SESSION_ID" ;;
    " Hibernate") systemctl hibernate ;;
    " Suspend") systemctl suspend ;;
esac
