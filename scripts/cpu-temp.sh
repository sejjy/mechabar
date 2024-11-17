#!/usr/bin/env bash

# Get CPU clock speeds
get_cpu_frequency() {
  freqlist=$(awk '/cpu MHz/ {print $4}' /proc/cpuinfo)
  maxfreq=$(sed 's/...$//' /sys/devices/system/cpu/cpu0/cpufreq/cpuinfo_max_freq)
  average_freq=$(echo "$freqlist" | tr ' ' '\n' | awk "{sum+=\$1} END {printf \"%.0f/%s MHz\", sum/NR, $maxfreq}")
  echo "$average_freq"
}

# Get CPU temperature
get_cpu_temperature() {
  temp=$(sensors | awk '/Package id 0/ {print $4}' | awk -F '[+.]' '{print $2}')
  if [[ -z "$temp" ]]; then
    temp=$(sensors | awk '/Tctl/ {print $2}' | tr -d '+°C')
  fi
  if [[ -z "$temp" ]]; then
    temp="N/A"
  else
    temp_f=$(awk "BEGIN {printf \"%.1f\", ($temp * 9 / 5) + 32}")
  fi
  echo "${temp:-N/A} ${temp_f:-N/A}"
}

# Get the corresponding icon based on temperature
get_temperature_icon() {
  temp_value=$1
  if [ "$temp_value" -ge 80 ]; then
    icon="󰸁" # High temperature
  elif [ "$temp_value" -ge 70 ]; then
    icon="󱃂" # Medium temperature
  elif [ "$temp_value" -ge 60 ]; then
    icon="󰔏" # Normal temperature
  else
    icon="󱃃" # Low temperature
  fi
  echo "$icon"
}

# Main script execution
cpu_frequency=$(get_cpu_frequency)
read -r temp_info < <(get_cpu_temperature)
temp=$(echo "$temp_info" | awk '{print $1}')   # Celsius
temp_f=$(echo "$temp_info" | awk '{print $2}') # Fahrenheit

# Determine the temperature icon
thermo_icon=$(get_temperature_icon "$temp")

# Set color based on temperature
if [ "$temp" -ge 80 ]; then
  # If temperature is >= 80%, set color to #f38ba8
  text_output="<span color='#f38ba8'>${thermo_icon} ${temp}°C</span>"
else
  # Default color
  text_output="${thermo_icon} ${temp}°C"
fi

tooltip="Temperature: ${temp_f}°F\nClock Speed: ${cpu_frequency}"

# Module and tooltip
echo "{\"text\": \"$text_output\", \"tooltip\": \"$tooltip\"}"
