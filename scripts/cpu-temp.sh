#!/usr/bin/env bash

model=$(awk -F ': ' '/model name/{print $2}' /proc/cpuinfo | head -n 1 | sed 's/@.*//; s/ *\((R)\|(TM)\)//g; s/^[ \t]*//; s/[ \t]*$//')

# Get CPU clock speeds
get_cpu_frequency() {
  freqlist=$(awk '/cpu MHz/ {print $4}' /proc/cpuinfo)
  maxfreq=$(sed 's/...$//' /sys/devices/system/cpu/cpu0/cpufreq/cpuinfo_max_freq 2>/dev/null || echo "N/A")
  if [ -n "$freqlist" ]; then
    average_freq=$(echo "$freqlist" | tr ' ' '\n' | awk "{sum+=\$1} END {printf \"%.0f/%s MHz\", sum/NR, \"$maxfreq\"}")
  else
    average_freq="N/A"
  fi
  echo "$average_freq"
}

# Get CPU temperature
get_cpu_temperature() {
  temp=$(sensors | awk '/Package id 0/ {print $4}' | awk -F '[+.]' '{print $2}' 2>/dev/null)
  if [[ -z "$temp" ]]; then
    temp=$(sensors | awk '/Tctl/ {print $2}' | tr -d '+°C' 2>/dev/null)
  fi
  if [[ -z "$temp" || ! "$temp" =~ ^[0-9]+(\.[0-9]+)?$ ]]; then
    temp="N/A"
    temp_f="N/A"
  else
    # Convertir a entero para comparaciones, pero mantener decimal para mostrar
    temp_int=${temp%.*}  # Tomar la parte entera
    temp_f=$(awk "BEGIN {printf \"%.1f\", ($temp * 9 / 5) + 32}")
  fi
  echo "$temp $temp_f $temp_int"
}

# Get the corresponding icon based on temperature
get_temperature_icon() {
  temp_value=$1
  if [ "$temp_value" = "N/A" ]; then
    icon="󱃃" # Default icon when temp is not available
  elif [ "$temp_value" -ge 80 ]; then
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
read -r temp temp_f temp_int < <(get_cpu_temperature)

# Determine the temperature icon using the integer value
thermo_icon=$(get_temperature_icon "${temp_int:-0}")

# Set color based on temperature
if [ "$temp_int" != "N/A" ] && [ "$temp_int" -ge 80 ]; then
  # If temperature is >= 80°C, set color to #f38ba8
  text_output="<span color='#f38ba8'>${thermo_icon} ${temp}°C</span>"
else
  # Default color
  text_output="${thermo_icon} ${temp}°C"
fi

tooltip="${model}\n"
tooltip+="Clock Speed: ${cpu_frequency}\nTemperature: ${temp_f}°F"

# Module and tooltip
echo "{\"text\": \"$text_output\", \"tooltip\": \"$tooltip\"}"
