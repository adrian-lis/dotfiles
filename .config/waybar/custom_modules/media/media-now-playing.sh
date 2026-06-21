#!/usr/bin/env bash

# Bezpieczne czyszczenie procesów zscroll przy restarcie paska
trap 'kill $(jobs -p) 2>/dev/null' EXIT

zscroll -l 20 \
    --delay 0.3 \
    --update-check true \
    "playerctl metadata --format '{{title}} - {{artist}}'" 2>/dev/null &

wait
