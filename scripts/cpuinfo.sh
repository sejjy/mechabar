#!/bin/bash

# Get CPU clock speeds
freqlist=$(awk '/cpu MHz/ {print $4}' /proc/cpuinfo)  # Extract clock speed in MHz
maxfreq=$(sed 's/...$//' /sys/devices/system/cpu/cpu0/cpufreq/cpuinfo_max_freq)  # Max CPU frequency
frequency=$(echo "$freqlist" | tr ' ' '\n' | awk "{sum+=\$1} END {printf \"%.0f/$maxfreq MHz\", sum/NR}")  # Average frequency

# Get CPU temperature in Celsius
temp=$(sensors | awk '/Package id 0/ {print $4}' | awk -F '[+.]' '{print $2}')  # Package temperature
if [[ -z "$temp" ]]; then
    temp=$(sensors | awk '/Tctl/ {print $2}' | tr -d '+°C')  # Fallback to Tctl if Package id 0 is empty
fi
if [[ -z "$temp" ]]; then
    temp="N/A"  # If no temp found, set to N/A
else
    temp_f=$(awk "BEGIN {printf \"%.1f\", ($temp * 9 / 5) + 32}")  # Convert Celsius to Fahrenheit
fi

# Map icons based on temperature and utilization
set_ico="{\"thermo\":{\"0\":\"󱃃\",\"45\":\"󰔏\",\"65\":\"󱃂\",\"85\":\"󰸁\"},\"util\":{\"0\":\"󰾆\",\"30\":\"󰾅\",\"60\":\"󰓅\",\"90\":\"󰀪\"}}"
eval_ico() {
    local key="$1"
    local value="$2"
    map_ico=$(echo "$set_ico" | jq -r --arg aky "$key" --argjson avl "$value" '.[$aky] | keys_unsorted | map(tonumber) | map(select(. <= $avl)) | max')
    echo "$set_ico" | jq -r --arg aky "$key" --arg avl "$map_ico" '.[$aky] | .[$avl]'  # Get the corresponding icon
}

thermo=$(eval_ico thermo "$temp")  # Get temperature icon

tooltip="Temperature: ${temp_f}°F"
tooltip+="\nClock Speed: ${frequency}"

# Module and tooltip
echo "{\"text\": \"${thermo} ${temp}°C\", \"tooltip\": \"$tooltip\"}"
