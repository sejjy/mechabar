#!/usr/bin/env bash

config="$HOME/.config/rofi/logout-menu.rasi"

actions=$(
  cat <<EOF
   Lock
   Shutdown
   Reboot
 󰏦  Suspend
   Hibernate
   Logout
EOF
)

# Display logout menu
selected_option=$(echo -e "$actions" | rofi -dmenu -i -config "${config}")

# Perform actions based on the selected option
case "$selected_option" in
"   Lock")
  hyprlock
  ;;
"   Shutdown")
  systemctl poweroff
  ;;
"   Reboot")
  systemctl reboot
  ;;
" 󰏦  Suspend")
  systemctl suspend
  ;;
"   Hibernate")
  systemctl hibernate
  ;;
"   Logout")
  hyprctl dispatch exit 0
  ;;
esac
