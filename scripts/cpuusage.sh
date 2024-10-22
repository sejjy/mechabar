#!/bin/bash

# Get CPU model (removed "(R)", "(TM)", and clock speed)
model=$(awk -F ': ' '/model name/{print $2}' /proc/cpuinfo | head -n 1 | sed 's/@.*//; s/ *\((R)\|(TM)\)//g; s/^[ \t]*//; s/[ \t]*$//')

# Get CPU usage percentage
load=$(vmstat 1 2 | tail -1 | awk '{print 100 - $15}')

# Determine CPU state based on usage
if [ "$load" -le 25 ]; then
    state="Low"
elif [ "$load" -le 50 ]; then
    state="Medium"
else
    state="High"
fi

# Set color based on CPU load
if [ "$load" -gt 80 ]; then
    # If CPU usage is above 80, set color to #f38ba8
    text_output="<span color='#f38ba8'>󰀩 ${load}%</span>"
else
    # Default color
    text_output="󰻠 ${load}%"
fi

tooltip="${model}"
tooltip+="\nCPU Usage: ${state}"

# Module and tooltip
echo "{\"text\": \"$text_output\", \"tooltip\": \"$tooltip\"}"
