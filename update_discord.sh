#!/bin/bash
# Discord Auto-Updater
# Usage: ./discord_update.sh [--manual]

set -e

DOWNLOAD_URL="https://discord.com/api/download?platform=linux&format=tar.gz"
INSTALL_DIR="/home/$USER/apps/discord"
TEMP_DIR="/tmp/discord-update"
SYMLINK_PATH="/usr/local/bin/discord"
BUILD_INFO="$INSTALL_DIR/resources/build_info.json"

# Ensure directories exist
mkdir -p "$INSTALL_DIR" "$TEMP_DIR"

# Get latest version from redirect URL
echo "Checking for updates..."
REDIRECT_URL=$(curl -sI "$DOWNLOAD_URL" | grep -i "^location:" | sed 's/location: //i' | tr -d '\r')
NEW_VERSION=$(echo "$REDIRECT_URL" | grep -oP 'discord-\K[0-9]+\.[0-9]+\.[0-9]+')

if [[ -z "$NEW_VERSION" ]]; then
    echo "Error: Could not determine latest version"
    exit 1
fi

echo "Latest version: $NEW_VERSION"

# Get current installed version from build_info.json
CURRENT_VERSION=""
if [[ -f "$BUILD_INFO" ]]; then
    CURRENT_VERSION=$(grep -oP '"version":\s*"\K[^"]+' "$BUILD_INFO" 2>/dev/null || echo "")
fi

echo "Installed version: ${CURRENT_VERSION:-none}"

# Compare versions
if [[ "$NEW_VERSION" == "$CURRENT_VERSION" ]] && [[ "$1" != "--manual" ]]; then
    echo "Already up to date (version: $CURRENT_VERSION)"
    rm -rf "$TEMP_DIR"
    exit 0
fi

# Download latest version
echo "Downloading Discord $NEW_VERSION..."
DOWNLOAD_FILE="$TEMP_DIR/discord-latest.tar.gz"
curl -L -o "$DOWNLOAD_FILE" "$DOWNLOAD_URL"

# Extract and install
echo "Installing Discord version: $NEW_VERSION"
tar -xzf "$DOWNLOAD_FILE" -C "$INSTALL_DIR" --strip-components=1

# Update symlink (requires sudo)
if [[ -w "$SYMLINK_PATH" ]] || sudo -n true 2>/dev/null; then
    sudo ln -sf "$INSTALL_DIR/Discord" "$SYMLINK_PATH"
    echo "Symlink updated at $SYMLINK_PATH"
else
    echo "Warning: Unable to update symlink. Run manually with sudo:"
    echo "  sudo ln -sf $INSTALL_DIR/Discord $SYMLINK_PATH"
fi

# Cleanup
rm -rf "$TEMP_DIR"

echo "Discord updated successfully to $NEW_VERSION"
