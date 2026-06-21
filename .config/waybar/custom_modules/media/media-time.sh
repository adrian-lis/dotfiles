#!/usr/bin/env bash

status=$(playerctl status 2>/dev/null)

if [[ "$status" == "Playing" || "$status" == "Paused" ]]; then
    playerctl metadata --format '{{duration(position)}}/{{duration(mpris:length)}}' 2>/dev/null
else
    echo ""
fi
