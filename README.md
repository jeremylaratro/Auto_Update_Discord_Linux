# Auto Update Discord on Linux
**What?** 
Simple script for updating Discord on Linux. This script will:
- auto-install Discord, if not already installed
- auto update Discord to latest version

For weekly auto-updates:
run: `crontab -e`
add: `0 3 * * 0 /home/$USER/apps/discord_update.sh`

Tested on Debian and Fedora.

Configurations:
- Script installs Discord to `/home/$USER/apps/`. Change this path in the script and crontab entry if you want it installed elsewhere. 

**Why?**
Discord constantly pushes out minor and patch versions, and doesn't allow the app to be run unless updated. With no automatic update feature for many Linux systems, this becomes very annoying.

**How?**
It just pulls the latest version, checks the version, extracts and installs if new, and symlinks to discord in /usr/local/bin. 
