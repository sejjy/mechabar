#!/usr/bin/env bash
gpu_info=$(nvidia-smi --query-gpu=gpu_name,temperature.gpu,memory.used,memory.total,utilization.gpu --format=csv,noheader,nounits)
gpu_name=$(echo "$gpu_info" | cut -d ',' -f 1)
gpu_temp=$(echo "$gpu_info" | cut -d ',' -f 2)
gpu_mem_used=$(echo "$gpu_info" | cut -d ',' -f 3)
gpu_mem_total=$(echo "$gpu_info" | cut -d ',' -f 4)
gpu_usage=$(echo "$gpu_info" | cut -d ',' -f 5)

tooltip="$gpu_name\n"
tooltip+="Temp: ${gpu_temp}°C\n"
tooltip+="Mem: ${gpu_mem_used}MiB / ${gpu_mem_total}MiB\n"
tooltip+="Usage: ${gpu_usage}%"

printf '{"text": "󰾲 %s%%", "tooltip": "%s"}\n' "$gpu_usage" "$tooltip"
