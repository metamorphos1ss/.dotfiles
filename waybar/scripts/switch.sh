#!/bin/bash

HEADPHONES_NAME="alsa_output.usb-Logitech_PRO_X_2_LIGHTSPEED_0000000000000000-00.analog-stereo"
HEADPHONES_ID=59
SPEAKERS_NAME="alsa_output.usb-Generic_PBS-250_20170726905923-01.analog-stereo"
SPEAKERS_ID=34

CURRENT_DEVICE=$(wpctl inspect @DEFAULT_AUDIO_SINK@ 2>/dev/null | grep "node.name" | awk -F'"' '{print $2}')

if [[ "$CURRENT_DEVICE" == "$HEADPHONES_NAME" ]]; then
  wpctl set-default "$SPEAKERS_ID"
else
  wpctl set-default "$HEADPHONES_ID"
fi
