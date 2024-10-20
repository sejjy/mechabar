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

tooltip="${model}"
tooltip+="\nCPU Usage: ${state}"

# Module and tooltip
echo "{\"text\": \"󰻠 ${load}%\", \"tooltip\": \"${tooltip}\"}"
