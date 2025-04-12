#!/bin/env bash

age -i ~/.age-key.txt -e ~/.config/rclone/rclone.conf >~/.local/share/chezmoi/home/.chezmoitemplates/rclone/encrypted_rclone.conf
