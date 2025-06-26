#!/usr/bin/env bash

# This script gathers detailed Wi-Fi connection information.
# It collects the following fields:
#
# - SSID (Service Set Identifier): The name of the Wi-Fi network you
#   are currently connected to.  Example: "My_Network"
#
# - IP Address: The IP address assigned to the device by the router.
#   This is typically a private IP within the local network.  Example:
#   "192.168.1.29/24" (with subnet mask)
#
# - Router (Gateway): The IP address of the router (default gateway)
#   that your device uses to communicate outside the local network.
#   Example: "192.168.1.1"
#
# - MAC Address: The unique Media Access Control address of the local
#   device's Wi-Fi adapter.  Example: "F8:34:41:07:1B:65"
#
# - Security: The encryption protocol being used to secure your Wi-Fi
#   connection. Common security protocols include:
#   - WPA2 (Wi-Fi Protected Access 2): The most commonly used security
#     standard, offering strong encryption (AES).
#   - WPA3: The latest version, providing even stronger security,
#     especially in public or open networks.
#   - WEP (Wired Equivalent Privacy): An outdated and insecure protocol
#     that should not be used.
#   Example: "WPA2" indicates that the connection is secured using WPA2
#   with AES encryption.
#
# - BSSID (Basic Service Set Identifier): The MAC address of the Wi-Fi
#   access point you are connected to.  Example: "A4:22:49:DA:91:A0"
#
# - Channel: The wireless channel your Wi-Fi network is using. This is
#   associated with the frequency band.  Example: "100 (5500 MHz)"
#   indicates the channel number (100) and the frequency (5500 MHz),
#   which is within the 5 GHz band.
#
# - RSSI (Received Signal Strength Indicator): The strength of the
#   Wi-Fi signal, typically in dBm (decibels relative to 1 milliwatt).
#   Closer to 0 means stronger signal, with values like -40 dBm being
#   very good.  Example: "-40 dBm"
#
# - Signal: The signal quality, which is represented as a percentage,
#   where higher numbers mean better signal.  Example: "100"
#   indicates perfect signal strength.
#
# - Rx Rate (Receive Rate): The maximum data rate (in Mbit/s) at which
#   the device can receive data from the Wi-Fi access point.  Example:
#   "866.7 MBit/s" indicates a high-speed connection on a modern
#   standard.
#
# - Tx Rate (Transmit Rate): The maximum data rate (in Mbit/s) at
#   which the device can send data to the Wi-Fi access point.  Example:
#   "866.7 MBit/s"
#
# - PHY Mode (Physical Layer Mode): The Wi-Fi protocol or standard in
#   use.  Common modes include 802.11n, 802.11ac, and 802.11ax (Wi-Fi
#   6).  Example: "802.11ac" indicates you're using the 5 GHz band with
#   a modern high-speed standard.

if ! command -v nmcli &>/dev/null; then
  echo "{\"text\": \"<span color='#f38ba8'>󰤫</span>\", \"tooltip\": \"nmcli utility is missing\"}"
  exit 1
fi

# Check if Wi-Fi is enabled
wifi_status=$(nmcli radio wifi)

if [ "$wifi_status" = "disabled" ]; then
  echo "{\"text\": \"󰤮\", \"tooltip\": \"Wi-Fi Disabled\"}"
  exit 0
fi

wifi_info=$(nmcli -t -f active,ssid,signal,security dev wifi | grep "^yes")

# If no ESSID is found, set a default value
if [ -z "$wifi_info" ]; then
  essid="No Connection"
  signal=0
  tooltip="No Connection"
else
  # Some defaults
  ip_address="127.0.0.1"
  # gateway="127.0.0.1"
  # mac_address="N/A"
  security=$(echo "$wifi_info" | awk -F: '{print $4}')
  # bssid="N/A"
  chan="N/A"
  # rssi="N/A"
  # rx_bitrate=""
  # tx_bitrate=""
  # phy_mode=""
  signal=$(echo "$wifi_info" | awk -F: '{print $3}')

  active_device=$(nmcli -t -f DEVICE,STATE device status |
    grep -w "connected" |
    grep -v -E "^(dummy|lo:|virbr0)" |
    awk -F: '{print $1}')

  if [ -n "$active_device" ]; then
    output=$(nmcli -e no -g ip4.address,ip4.gateway,general.hwaddr device show "$active_device")

    ip_address=$(echo "$output" | sed -n '1p')
    # gateway=$(echo "$output" | sed -n '2p')
    # mac_address=$(echo "$output" | sed -n '3p')

    line=$(nmcli -e no -t -f active,bssid,chan,freq device wifi | grep "^yes")

    # bssid=$(echo "$line" | awk -F':' '{print $2":"$3":"$4":"$5":"$6":"$7}')
    chan=$(echo "$line" | awk -F':' '{print $8}')
    freq=$(echo "$line" | awk -F':' '{print $9}')
    chan="$chan ($freq)"

    # if command -v iw &>/dev/null; then
    # iw_output=$(iw dev "$active_device" station dump)
    # rssi=$(echo "$iw_output" | grep "signal:" | awk '{print $2 " dBm"}')

    # Upload speed
    # rx_bitrate=$(echo "$iw_output" | grep "rx bitrate:" | awk '{print $3 " " $4}')

    # Download speed
    # tx_bitrate=$(echo "$iw_output" | grep "tx bitrate:" | awk '{print $3 " " $4}')

    # Physical Layer Mode
    # if echo "$iw_output" | grep -E -q "rx bitrate:.* VHT"; then
    #   phy_mode="802.11ac" # Wi-Fi 5
    # elif echo "$iw_output" | grep -E -q "rx bitrate:.* HT"; then
    #   phy_mode="802.11n" # Wi-Fi 4
    # elif echo "$iw_output" | grep -E -q "rx bitrate:.* HE"; then
    #   phy_mode="802.11ax" # Wi-Fi 6
    # fi
    # fi

    # Get the current Wi-Fi ESSID
    essid=$(echo "$wifi_info" | awk -F: '{print $2}')

    tooltip=":: ${essid}"
    tooltip+="\nIP Address: ${ip_address}"
    # tooltip+="\nRouter:      ${gateway}"
    # tooltip+="\nMAC Address: ${mac_address}"
    tooltip+="\nSecurity:   ${security}"
    # tooltip+="\nBSSID:       ${bssid}"
    tooltip+="\nChannel:    ${chan}"
    # tooltip+="\nRSSI:        ${rssi}"
    tooltip+="\nStrength:   ${signal} / 100"

    # if [ -n "$rx_bitrate" ]; then
    #   tooltip+="\nRx Rate:     ${rx_bitrate}"
    # fi

    # if [ -n "$tx_bitrate" ]; then
    #   tooltip+="\nTx Rate:     ${tx_bitrate}"
    # fi

    # if [ -n "$phy_mode" ]; then
    #   tooltip+="\nPHY Mode:    ${phy_mode}"
    # fi
  fi
fi

# Determine Wi-Fi icon based on signal strength
if [ "$signal" -ge 80 ]; then
  icon="󰤨" # Strong signal
elif [ "$signal" -ge 60 ]; then
  icon="󰤥" # Good signal
elif [ "$signal" -ge 40 ]; then
  icon="󰤢" # Weak signal
elif [ "$signal" -ge 20 ]; then
  icon="󰤟" # Very weak signal
else
  icon="<span color='#f38ba8'>󰤯</span>" # No signal
fi

# Module and tooltip
echo "{\"text\": \"${icon}\", \"tooltip\": \"${tooltip}\"}"
