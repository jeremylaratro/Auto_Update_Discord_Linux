#!/bin/bash
# Discord Auto-Updater
# Usage: ./discord_update.sh [--manual]

set -e
DOWNLOAD_URL="https://discord.com/api/download?platform=linux&format=tar.gz"
INSTALL_DIR="/home/$USER/apps/discord"
TEMP_DIR="/tmp/discord-update"
SYMLINK_PATH="/usr/local/bin/discord"
VERSION_FILE="$INSTALL_DIR/.current_version"

# Ensure directories exist
mkdir -p "$INSTALL_DIR" "$TEMP_DIR"

# Download latest version
echo "Downloading latest Discord..."
DOWNLOAD_FILE="$TEMP_DIR/discord-latest.tar.gz"
curl -L -o "$DOWNLOAD_FILE" "$DOWNLOAD_URL"

# Extract version from tar.gz (Discord package contains a version in the folder name)
TEMP_EXTRACT="$TEMP_DIR/extract"
mkdir -p "$TEMP_EXTRACT"
tar -tzf "$DOWNLOAD_FILE" | head -1 | cut -f1 -d"/" > "$TEMP_DIR/new_version"
NEW_VERSION=$(cat "$TEMP_DIR/new_version")

# Check if version file exists and compare
if [[ -f "$VERSION_FILE" ]]; then
    CURRENT_VERSION=$(cat "$VERSION_FILE")
    if [[ "$NEW_VERSION" == "$CURRENT_VERSION" ]] && [[ "$1" != "--manual" ]]; then
        echo "Already up to date (version: $CURRENT_VERSION)"
        rm -rf "$TEMP_DIR"
        exit 0
    fi
fi

# Extract and install
echo "Installing Discord version: $NEW_VERSION"
tar -xzf "$DOWNLOAD_FILE" -C "$INSTALL_DIR" --strip-components=1

# Update version file
echo "$NEW_VERSION" > "$VERSION_FILE"

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
echo "# Add cronjob for automatic weekly updates: 
run: crontab -e
add: 0 3 * * 0 /home/$USER/apps/discord_update.sh"
