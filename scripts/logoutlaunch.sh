#!/bin/bash

# Check if wlogout is already running
if pgrep -x "wlogout" > /dev/null; then
    pkill -x "wlogout"
    exit 0
fi

# Define configuration directories
confDir="${XDG_CONFIG_HOME:-$HOME/.config}"

# Style selection
[ -z "${1}" ] || wlogoutStyle="${1}"
wLayout="${confDir}/wlogout/layout_${wlogoutStyle}"
wlTmplt="${confDir}/wlogout/style_${wlogoutStyle}.css"

if [ ! -f "${wLayout}" ] || [ ! -f "${wlTmplt}" ]; then
    echo "ERROR: Config ${wlogoutStyle} not found..."
    wlogoutStyle=1
    wLayout="${confDir}/wlogout/layout_${wlogoutStyle}"
    wlTmplt="${confDir}/wlogout/style_${wlogoutStyle}.css"
fi

# Detect monitor resolution
x_mon=$(hyprctl -j monitors | jq '.[] | select(.focused==true) | .width')
y_mon=$(hyprctl -j monitors | jq '.[] | select(.focused==true) | .height')
hypr_scale=$(hyprctl -j monitors | jq '.[] | select(.focused == true) | .scale' | sed 's/\.//')

# Scale config layout and style
case "${wlogoutStyle}" in
    1)
        wlColms=6
        export mgn=$(( y_mon * 38 / hypr_scale ))
        export hvr=$(( y_mon * 33 / hypr_scale ))
        ;;
    2)
        wlColms=2
        export x_mgn=$(( x_mon * 38 / hypr_scale ))
        export y_mgn=$(( y_mon * 28 / hypr_scale ))
        export x_hvr=$(( x_mon * 35 / hypr_scale ))
        export y_hvr=$(( y_mon * 23 / hypr_scale ))
        ;;
esac

# Scale font size
export fntSize=$(( y_mon * 2 / 100 ))

export BtnCol="white"  # Default button color

# Evaluate hypr border radius
hypr_border="$(hyprctl -j getoption decoration:rounding | jq '.int')"
export hypr_border
export active_rad=$(( hypr_border * 5 ))
export button_rad=$(( hypr_border * 8 ))

# Evaluate config files
wlStyle=$(envsubst < "$wlTmplt")

# Launch wlogout
wlogout -b "${wlColms}" -c 0 -r 0 -m 0 --layout "${wLayout}" --css <(echo "${wlStyle}") --protocol layer-shell
