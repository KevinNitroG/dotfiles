#!/usr/bin/env bash

chown -R "$(whoami)" ~/.gnupg/
find ~/.gnupg -type d -exec chmod 700 {} \;
find ~/.gnupg -type f -exec chmod 600 {} \;
