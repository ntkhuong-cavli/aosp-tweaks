#!/bin/bash
set -e

CURRENT_USER=$(whoami)

echo "[env_init] Running as user: $CURRENT_USER"

SOURCE_LINE="source /opt/etc/bashrc"

# Check if user is root
if [ "$CURRENT_USER" = "root" ]; then
    BASHRC="/root/.bashrc"
else
    BASHRC="/home/$CURRENT_USER/.bashrc"
fi

# Create .bashrc if not exists
touch "$BASHRC"

# Add source line if not already present
if ! grep -qxF "$SOURCE_LINE" "$BASHRC"; then
    echo "$SOURCE_LINE" >> "$BASHRC"
    echo "[env_init] Added source line to $BASHRC"
else
    echo "[env_init] Source line already present in $BASHRC"
fi
