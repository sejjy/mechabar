#!/bin/bash

# Check if necessary utilities are installed
if ! command -v nmcli &> /dev/null || ! command -v iw &> /dev/null; then
  echo "{\"text\": \"󰤮 Wi-Fi\", \"tooltip\": \"Wi-Fi utilities are missing\"}"
  exit 1
fi

wifi_info=$(nmcli -t -f active,ssid,signal dev wifi | grep "^yes")

# If no ESSID is found, set a default value
if [ -z "$wifi_info" ]; then
  essid="No Connection"
  signal=0
else
  # Some defaults
  ip_address="127.0.0.1"
  gateway="127.0.0.1"
  mac_address="N/A"
  bssid="N/A"
  chan="N/A"
  rssi="N/A"
  rx_bitrate=""
  tx_bitrate=""
  signal=$(echo $wifi_info | awk -F: '{print $3}')

  active_device=$(nmcli -t -f DEVICE,STATE device status | \
    grep -w "connected" | \
    grep -v -E "^(dummy|lo:)" | \
    awk -F: '{print $1}')

  if [ -n "$active_device" ]; then
    output=$(nmcli -e no -g ip4.address,ip4.gateway,general.hwaddr device show $active_device)

    ip_address=$(echo "$output" | sed -n '1p')
    gateway=$(echo "$output" | sed -n '2p')
    mac_address=$(echo "$output" | sed -n '3p')

    line=$(nmcli -e no -t -f active,bssid,chan,freq device wifi | grep "^yes")

    bssid=$(echo "$line" | awk -F':' '{print $2":"$3":"$4":"$5":"$6":"$7}')
    chan=$(echo "$line" | awk -F':' '{print $8}')
    freq=$(echo "$line" | awk -F':' '{print $9}')
    chan="$chan ($freq)"

    iw_output=$(iw dev "$active_device" station dump)
    rssi=$(echo "$iw_output" | grep "signal:" | awk '{print $2 " dBm"}')

    # Upload speed
    rx_bitrate=$(echo "$iw_output" | grep "rx bitrate:" | awk '{print $3 " " $4}')

    # Download speed
    tx_bitrate=$(echo "$iw_output" | grep "tx bitrate:" | awk '{print $3 " " $4}')
  fi

  # Get the current Wi-Fi ESSID
  essid=$(echo $wifi_info | awk -F: '{print $2}')

  tooltip="$essid\n"
  tooltip+="\nIP Address:  ${ip_address}"
  tooltip+="\nRouter:      ${gateway}"
  tooltip+="\nMAC Address: ${mac_address}"
  tooltip+="\nBSSID:       ${bssid}"
  tooltip+="\nChannel:     ${chan}"
  tooltip+="\nRSSI:        ${rssi}"
  tooltip+="\nSignal:      ${signal}"

  if [ -n "$rx_bitrate" ]; then
    tooltip+="\nRx Rate:     ${rx_bitrate}"
  fi

  if [ -n "$tx_bitrate" ]; then
    tooltip+="\nTx Rate:     ${tx_bitrate}"
  fi
fi

# Determine Wi-Fi icon based on signal strength
if [ "$signal" -ge 80 ]; then
  icon="󰤨"  # Strong signal
elif [ "$signal" -ge 60 ]; then
  icon="󰤥"  # Good signal
elif [ "$signal" -ge 40 ]; then
  icon="󰤢"  # Weak signal
elif [ "$signal" -ge 20 ]; then
  icon="󰤟"  # Very weak signal
else
  icon="󰤮"  # No signal
fi

# Change "Wi-Fi" to "${essid}" to display network name
echo "{\"text\": \"${icon} Wi-Fi\", \"tooltip\": \"${tooltip}\"}"
