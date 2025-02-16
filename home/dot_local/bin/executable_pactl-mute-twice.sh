#!/usr/bin/env bash

# Mute and unmute to make the audio work

if ! command -v pactl >/dev/null 2>&1; then
  echo "pactl isn't installed"
  exit 1
fi

pactl set-sink-mute 0 toggle
sleep 1
pactl set-sink-mute 0 toggle
