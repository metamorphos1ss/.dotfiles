#!/usr/bin/bash

HEADPHONES_HUMAN="PRO X 2 LIGHTSPEED Analog Stereo"
SPEAKERS_HUMAN="PBS-250 Analog Stereo"

HEADPHONES_SYS="alsa_output.usb-Logitech_PRO_X_2_LIGHTSPEED_0000000000000000-00.analog-stereo"
SPEAKERS_SYS="alsa_output.usb-Generic_PBS-250_20170726905923-01.analog-stereo"

# Весь вывод wpctl один раз
STATUS=$(wpctl status)

current_default() {
  echo "$1" | grep "Audio/Sink" | awk '{print $3}'
}

get_sink_id() {
  echo "$1" | awk -v name="$2" '
    BEGIN { in_sinks=0 }
    /Sinks:/ { in_sinks=1; next }
    in_sinks && /^\s*└─/ { exit }
    in_sinks && index($0, name) {
        match($0, /[0-9]+/)
        print substr($0, RSTART, RLENGTH)
        exit
    }'
}

current_sys=$(current_default "$STATUS")

if [[ "$current_sys" == "$HEADPHONES_SYS" ]]; then
  TARGET_ID=$(get_sink_id "$STATUS" "$SPEAKERS_HUMAN")
else
  TARGET_ID=$(get_sink_id "$STATUS" "$HEADPHONES_HUMAN")
fi

wpctl set-default "$TARGET_ID"
