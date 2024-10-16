#!/usr/bin/env sh

# CPU model
model=$(cat /proc/cpuinfo | grep 'model name' | head -n 1 | awk -F ': ' '{print $2}' | sed 's/@.*//' | sed 's/(R)//g' | sed 's/(TM)//g')

# Get CPU load (usage percentage)
load=$(vmstat 1 2 | tail -1 | awk '{print 100 - $15}')

# Determine the CPU state based on the load
if [ "$load" -le 25 ]; then
    state="Low"
elif [ "$load" -le 50 ]; then
    state="Medium"
else
    state="High"
fi

# CPU icon
icon="󰻠"

echo "{\"text\":\"${icon} ${load}%\", \"tooltip\":\"${model}\n${icon} CPU Usage: ${state}\"}"
