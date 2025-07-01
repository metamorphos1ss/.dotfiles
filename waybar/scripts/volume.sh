#!/usr/bin/bash

VOLUME=$(wpctl get-volume @DEFAULT_AUDIO_SINK@ 2>/dev/null | awk '{printf "%.0f", $2 * 100}')
DEVICE_NAME=$(wpctl inspect @DEFAULT_AUDIO_SINK@ | grep "node.name" | awk -F '"' '{print $2}')

ICON=""

if echo "$DEVICE_NAME" | grep -iq "Logitech"; then
  ICON="󰋋"
else
  ICON="󰓃"
fi

echo "$ICON $VOLUME%"
